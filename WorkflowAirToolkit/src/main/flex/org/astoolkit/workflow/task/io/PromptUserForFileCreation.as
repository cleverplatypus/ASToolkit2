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
package org.astoolkit.workflow.task.io
{
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.core.ExitStatus;
	
	/**
	 * Opens the OS's file save dialog.
	 *
	 * <p>
	 * <b>Output</b><br><br>
	 * either a <code>flash.filesystem.File</code> or <code>flash.filesystem.FileStream</code>
	 * depending on the value of <code>outputType</code>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>message</code>: the text to display in the file save dialog</li>
	 * <li><code>fileMode</code>: if <code>outputType</code> is "stream", the file mode</li>
	 * <li><code>outputType</code>: either "file" or "stream"</li>
	 * </ul>
	 * </p>
	 */
	public class PromptUserForFileCreation extends BaseTask
	{
		public static const OUTPUT_FILE : String = "file";
		
		public static const OUTPUT_STREAM : String = "stream";
		
		[Inspectable( enumeration="write,append,read,update", defaultValue="write" )]
		public var fileMode : String = "write";
		
		public var message : String;
		
		[Inspectable( enumeration="file,stream", defaultValue="file" )]
		public var outputType : String;
		
		private var _fileSelector : File;
		
		override public function begin() : void
		{
			super.begin();
			_fileSelector = new File();
			_fileSelector.addEventListener( Event.SELECT, onFileSelect );
			_fileSelector.addEventListener( Event.CANCEL, onSelectCancel );
			_fileSelector.browseForSave( message ? message : "" );
		}
		
		private function onFileSelect( inEvent : Event ) : void
		{
			if(outputType == OUTPUT_STREAM)
			{
				var stream : FileStream = new FileStream();
				var out : *;
				var m : String;
				
				switch(fileMode)
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
				stream.open( _fileSelector, m );
				out = stream;
			}
			else
				out = _fileSelector;
			complete( out );
		}
		
		private function onSelectCancel( inEvent : Event ) : void
		{
			_exitStatus = new ExitStatus( ExitStatus.USER_CANCELED );
			fail( "User canceled file save" );
		}
	}
}
