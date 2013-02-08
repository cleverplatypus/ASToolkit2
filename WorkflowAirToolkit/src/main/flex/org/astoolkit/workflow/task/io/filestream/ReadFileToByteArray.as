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
package org.astoolkit.workflow.task.io.filestream
{

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import org.astoolkit.workflow.core.BaseTask;

	public class ReadFileToByteArray extends BaseTask
	{

		private var _file : File;

		private var _uri : String;

		[Inspectable( enumeration="big,little", defaultValue="big" )]
		public var endian : String

		[InjectPipeline]
		public function set file( inValue :File) : void
		{
			_onPropertySet( "file" );
			_file = inValue;
		}

		[InjectPipeline]
		public function set uri( inValue :String) : void
		{
			_onPropertySet( "uri" );
			_uri = inValue;
		}

		override public function begin() : void
		{
			super.begin();
			var aFile : File;

			if( !_file && !_uri )
			{
				fail( "No _file or _uri parameter set" );
				return;
			}

			if( _file )
				aFile = _file;
			else
				aFile = new File( _uri );

			if( !aFile.exists )
			{
				fail( "File with url \"{0}\" does not exist", aFile.url );
				return;
			}
			var fs : FileStream = new FileStream();
			fs.endian = endian == "big" ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN;
			fs.open( aFile, FileMode.READ );
			var out : ByteArray = new ByteArray();
			fs.readBytes( out );
			complete( out );
		}
	}
}
