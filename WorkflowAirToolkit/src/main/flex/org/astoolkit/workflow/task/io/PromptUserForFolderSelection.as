package org.astoolkit.workflow.task.io
{
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.core.ExitStatus;
	import org.astoolkit.workflow.task.io.util.FileFilter;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileReference;
	
	[Bindable]
	public class PromptUserForFolderSelection extends BaseTask
	{
		private var _file : File;
		public var filters : Vector.<FileFilter>;
		public var prompt : String = "Select file";
		
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
			return;
		}
		
		private function onFileSelect( inEvent : Event ) : void
		{
			complete( inEvent.target );
		}
		
	}
}