/*

Copyright 2009 Nicola Dal Pont

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Version 2.x

*/
package org.astoolkit.commons.utils
{

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import mx.rpc.IResponder;

	public final class SWCLibraryExtractor extends EventDispatcher
	{

		public function SWCLibraryExtractor( inSwcFile : File )
		{
			super( this );
			_swcFile = inSwcFile;

			if( !inSwcFile || !inSwcFile.exists || !inSwcFile.extension.match( /swc$/i ) )
				throw( new Error( "Provided file doesn't seem to be a SWC file" ) );
		}

		private var _responder : IResponder;

		private var _swcFile : File;

		public function extractSWFLibrary( inResponder : IResponder ) : void
		{
			_responder = inResponder;
			_swcFile.addEventListener( Event.COMPLETE, onSWCLoaded );
			_swcFile.load();
		}

		private function onSWCLoaded( inEvent : Event ) : void
		{
			var data : ByteArray = _swcFile.data;
			data.endian = Endian.LITTLE_ENDIAN;

			var sign : uint = data.readUnsignedInt();

			while( sign == 0x04034b50 )
			{
				try
				{
					var version : uint = data.readUnsignedShort();
					var gBitFlag : uint = data.readUnsignedShort();
					var compressionMethod : uint = data.readUnsignedShort();
					var lastmodFileTime : uint = data.readUnsignedShort();
					var lastModFileDate : uint = data.readUnsignedShort();
					var crc32 : uint = data.readUnsignedInt();
					var cLen : uint = data.readUnsignedInt();
					var uLen : uint = data.readUnsignedInt();
					var fNameLen : uint = data.readUnsignedShort();
					var extraLen : uint = data.readUnsignedShort();
					var fileName : String = data.readUTFBytes( fNameLen );
					data.position += extraLen;

					if( data.readUnsignedInt() == 0x04034b50 )
						continue;
					else
						data.position -= 4;

					var compData : ByteArray = readContent( data, fileName );

					if( fileName == "library.swf" )
					{
						compData.inflate();

						if( _responder )
							_responder.result( compData );
						return;
					}
					else
					{
						if( data.bytesAvailable >= 4 )
						{
							var testUint : uint = data.readUnsignedInt();

							if( testUint == 0x04034b50 )
								continue;

							if( testUint == 0x02014b50 )
								return;
						}
					}
					sign = 0;
				}
				catch( e : Error )
				{
					if( _responder )
						_responder.fault( e );
					return;
				}
			}
		}

		private function readContent( inData : ByteArray, inFileName : String ) : ByteArray
		{
			var compressedBytes : ByteArray = new ByteArray();
			compressedBytes.endian = Endian.LITTLE_ENDIAN;

			var testUint : uint;

			do
			{

				if( inData.bytesAvailable == 0 )
				{
					return compressedBytes;
				}
				compressedBytes.writeByte( inData.readUnsignedByte() );

				if( compressedBytes.length >= 4 )
				{
					compressedBytes.position = compressedBytes.length - 4;
					testUint = compressedBytes.readUnsignedInt();

					if( testUint == 0x04034b50 || testUint == 0x02014b50 )
					{
						compressedBytes.length -= 4;
						return compressedBytes;
					}
				}
			} while( true )
			return null;
		}
	}
}

