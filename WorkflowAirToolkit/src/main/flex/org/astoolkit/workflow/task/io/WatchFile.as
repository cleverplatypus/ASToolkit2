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

	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Checks <code>file</code>'s modification time every <code>frequency</code>
	 * milliseconds and completes if it's different from the one
	 * captured when this task was started.
	 * <p>The passed file can be any plain file or a directory. In the latter case
	 * the task completes when either the directory name or its content changes</p>
	 *
	 * <b>Input</b>
	 * <ul>
	 * <li>a <code>flash.filesystem.File</code> object</li>
	 * </ul>
	 * <b>No Output</b>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>frequency</code>: the number of milliseconds between checks</li>
	 * <li><code>file</code> (injectable): the file to watch</li>
	 * </ul>
	 * </p>
	 */
	public class WatchFile extends BaseTask
	{

		[Bindable]
		[InjectPipeline]
		public var file : File;

		public var frequency : int = 5000;

		public var ignorePatterns : Array;

		public var includePatterns : Vector.<RegExp>;

		public var recursive : Boolean;

		private var _originalTimestamp : Date;

		private var _timer : Timer;

		override public function begin() : void
		{
			super.begin();

			if( !file )
			{
				fail( "No directory set" );
				return;
			}
			getNewerModificationDate( file );
			_timer.addEventListener( TimerEvent.TIMER, threadSafe( onTimer ) );
			_timer.start();
		}

		override public function cleanUp() : void
		{
			super.cleanUp();

			if( _timer )
			{
				_timer.stop();
				_timer = null;
			}
		}

		override public function initialize() : void
		{
			super.initialize();
			_timer = new Timer( frequency );
		}

		private function getNewerModificationDate( inFile : File ) : void
		{
			_originalTimestamp = inFile.modificationDate;
			return;

			if( !inFile.isDirectory )
			{
				if( _originalTimestamp == null || _originalTimestamp.getTime() < inFile.modificationDate.getTime() )
					_originalTimestamp = inFile.modificationDate;
			}
			else
			{
				for each( var child : File in inFile.getDirectoryListing() )
				{
					if( shouldIncludeFile( child ) && !shouldIgnoreFile( child ) )
						getNewerModificationDate( child );
				}
			}
		}

		private function isDescendantChanged( inDir : File ) : Boolean
		{
			for each( var file : File in inDir.getDirectoryListing() )
			{
				if( !shouldIncludeFile( file ) || shouldIgnoreFile( file ) )
					continue;

				if( file.modificationDate.getTime() > _originalTimestamp.getTime() )
					return true;

				if( file.isDirectory && isDescendantChanged( file ) )
					return true;
			}
			return false;
		}

		private function onTimer( inEvent : TimerEvent ) : void
		{
			if( ( file.modificationDate.getTime() > _originalTimestamp.getTime() ) ||
				( recursive && file.isDirectory && isDescendantChanged( file ) ) )
			{
				_timer.stop();
				complete();
			}
		}

		private function shouldIgnoreFile( inFile : File ) : Boolean
		{
			if( !ignorePatterns || ignorePatterns.length == 0 )
				return false;

			for each( var re : RegExp in ignorePatterns )
			{
				if( inFile.name.match( re ) )
					return true;
			}
			return false;
		}

		private function shouldIncludeFile( inFile : File ) : Boolean
		{
			if( !includePatterns || includePatterns.length == 0 )
				return true;

			for each( var re : RegExp in includePatterns )
			{
				if( inFile.name.match( re ) )
					return true;
			}
			return false;
		}
	}
}
