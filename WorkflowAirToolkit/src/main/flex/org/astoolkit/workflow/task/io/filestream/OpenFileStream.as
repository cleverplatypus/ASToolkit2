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
	import org.astoolkit.workflow.core.BaseTask;

	public class OpenFileStream extends BaseTask
	{

		private var _file : File;

		private var _path : String;

		[InjectPipeline]
		public function set file( inValue :File) : void
		{
			_onPropertySet( "file" );
			_file = inValue;
		}

		[Inspectable( enumeration="write,append,read,update", defaultValue="write" )]
		public var mode : String;

		[InjectPipeline]
		public function set path( inValue :String) : void
		{
			_onPropertySet( "path" );
			_path = inValue;
		}

		override public function begin() : void
		{
			super.begin();

			if( !_file && !_path )
			{
				fail( "No file or path property set" );
				return;
			}
			var aFile : File;

			if( _file )
				aFile = _file;
			else
			{
				aFile = new File();

				if( _path.match( /^\w+:\// ) )
					aFile.url = _path;
				else
					aFile.nativePath = _path;
			}

			if( mode == "read" && !aFile.exists )
			{
				fail( "Cannot open a read stream on a non existing file" );
				return;
			}
			var stream : FileStream = new FileStream();
			var m : String;

			switch( mode )
			{
				case "write":
					m = FileMode.WRITE;
					break
				case "append":
					m = FileMode.APPEND;
					break
				case "read":
					m = FileMode.READ;
					break
				case "update":
					m = FileMode.UPDATE;
					break
			}
			stream.open( aFile, m );
			complete( stream );
		}
	}
}
