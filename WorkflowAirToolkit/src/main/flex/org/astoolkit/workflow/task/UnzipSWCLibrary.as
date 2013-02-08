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
package org.astoolkit.workflow.task
{

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import mx.rpc.Responder;
	import org.astoolkit.commons.utils.SWCLibraryExtractor;
	import org.astoolkit.workflow.core.BaseTask;

	[TaskInput( "flash.filesystem.File" )]
	public class UnzipSWCLibrary extends BaseTask
	{

		private var _extractor : SWCLibraryExtractor;

		private var _swcFile : File;

		[Inspectable( enumeration="bytearray,tempfile" )]
		override public function set outputKind( inValue : String ) : void
		{
			super.outputKind = inValue;
		}

		[InjectPipeline]
		public function set swcFile( inValue :File) : void
		{
			_onPropertySet( "swcFile" );
			_swcFile = inValue;
		}

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();
			_extractor = new SWCLibraryExtractor( _swcFile );
			_extractor.extractSWFLibrary( new Responder( onExtractorSuccess, onExtractorFault ) );
		}

		private function onExtractorFault( inErr : Error ) : void
		{
			fail( "SWF extraction failed.\n{0}", inErr.getStackTrace() );
		}

		private function onExtractorSuccess( inData : ByteArray ) : void
		{
			if( _outputKind == "bytearray" )
				complete( inData );
			else
			{
				var file : File = File.createTempFile();
				var stream : FileStream = new FileStream();
				stream.endian = Endian.LITTLE_ENDIAN;
				stream.open( file, FileMode.WRITE );
				stream.writeBytes( inData, 0, inData.bytesAvailable );
				stream.close();
				complete( file );
			}
		}
	}
}
