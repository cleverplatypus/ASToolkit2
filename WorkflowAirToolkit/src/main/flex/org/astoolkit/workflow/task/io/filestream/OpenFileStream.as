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

*/package org.astoolkit.workflow.task.io.filestream
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import org.astoolkit.workflow.core.BaseTask;
	
	public class OpenFileStream extends BaseTask
	{
		
		[Bindable][InjectPipeline]
		public var file : File;
		
		[Bindable][InjectPipeline]
		public var path : String;
		
		[Inspectable(enumeration="write,append,read,update", defaultValue="write")]
		public var mode : String;
		
		override public function begin() : void
		{
			super.begin();
			if( !file && !path )
			{
				fail( "No file or path property set" );
				return;
			}
			var aFile : File;
			if( file )
				aFile = file;
			else
			{
				aFile = new File();
				if( path.match( /^\w+:\// ) )
					aFile.url = path;
				else
					aFile.nativePath = path;
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