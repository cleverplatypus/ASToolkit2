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
package org.astoolkit.workflow.task.flowcontrol
{

	import org.astoolkit.workflow.api.ITasksGroup;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.internals.GroupUtil;

	public class LastIteration extends BaseTask
	{
		public var atCount : uint = 0;

		private var _currentCount : uint = 0;

		private var _lastParentThread : uint;

		override public function begin() : void
		{
			super.begin();

			if( !_currentIterator )
			{
				fail( "Task {0} isn't inside a valid iteration", description );
			}
			_currentCount++;

			if( atCount == _currentCount )
			{
				_currentIterator.abort();
			}
			complete();
		}

		override public function prepare() : void
		{
			super.prepare();
			var p : ITasksGroup = GroupUtil.getParentWorkflow( this );

			if( _lastParentThread != p.currentThread )
			{
				_lastParentThread = p.currentThread;
				_currentCount = 0;
			}
		}
	}
}
