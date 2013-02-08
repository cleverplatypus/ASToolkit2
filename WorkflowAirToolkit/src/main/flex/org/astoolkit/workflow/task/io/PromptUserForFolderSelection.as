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
	import flash.net.FileReference;
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.core.ExitStatus;
	import org.astoolkit.workflow.task.io.util.FileFilter;

	[Bindable]
	public class PromptUserForFolderSelection extends BaseTask
	{
		public var filters : Vector.<FileFilter>;

		public var prompt : String = "Select file";

		private var _file : File;

		override public function begin() : void
		{
			super.begin();
			_file = new File();
			_file.addEventListener( Event.SELECT, threadSafe( onFileSelect ) );
			_file.addEventListener( Event.CANCEL, threadSafe( onBrowseCancel ) );
			var fFilters : Array = [];

			for each( var filter : FileFilter in filters )
				fFilters.push( new flash.net.FileFilter( filter.description, filter.extension ) );
			_file.browseForDirectory( prompt );
		}

		private function onBrowseCancel( inEvent : Event ) : void
		{
			exitStatus = new ExitStatus( ExitStatus.USER_CANCELED );
			fail( "User canceled directory selection" );
			return;
		}

		private function onFileSelect( inEvent : Event ) : void
		{
			complete( inEvent.target );
		}
	}
}
