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
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.core.ExitStatus;
	import org.astoolkit.workflow.task.io.util.FileFilter;

	/**
	 * Opens the OS's file open dialog.
	 *
	 * <p>
	 * <b>Output</b><br><br>
	 * a <code>flash.filesystem.File</code> or an Array of <code>flash.filesystem.File</code>
	 * objects if <code>multiple</code> is set to true
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>message</code>: the text to display in the file open dialog</li>
	 * <li><code>filters</code>: a Vector of <code>org.astoolkit.workflow.task.io.util.FileFilter</code> objects</li>
	 * <li><code>multiple</code>: if true, the output will be an array of one or more <code>flash.filesystem.File</code> objects</li>
	 * </ul>
	 * </p>
	 */
	public class PromptUserForFileSelection extends BaseTask
	{
		public var filters : Vector.<FileFilter>;

		public var message : String = "Select file";

		public var multiple : Boolean;

		public var selectDirectory : Boolean;

		private var _file : File;

		override public function begin() : void
		{
			super.begin();
			_file = new File();

			if( multiple && !selectDirectory )
				_file.addEventListener( FileListEvent.SELECT_MULTIPLE, threadSafe( onMultipleFilesSelect ) );
			else
				_file.addEventListener( Event.SELECT, threadSafe( onFileSelect ) );
			_file.addEventListener( Event.CANCEL, threadSafe( onBrowseCancel ) );
			var fFilters : Array = [];

			if( selectDirectory )
			{
				_file.browseForDirectory( message );
			}
			else
			{
				for each( var filter : FileFilter in filters )
					fFilters.push( new flash.net.FileFilter( filter.description, filter.extension ) );

				if( multiple )
					_file.browseForOpenMultiple( message, fFilters );
				else
					_file.browseForOpen( message, fFilters );
			}
		}

		private function onBrowseCancel( inEvent : Event ) : void
		{
			exitStatus = new ExitStatus( ExitStatus.USER_CANCELED );
			fail( "User canceled file selection" );
		}

		private function onFileSelect( inEvent : Event ) : void
		{
			complete( inEvent.target );
		}

		private function onMultipleFilesSelect( inEvent : FileListEvent ) : void
		{
			complete( inEvent.files );
		}
	}
}
