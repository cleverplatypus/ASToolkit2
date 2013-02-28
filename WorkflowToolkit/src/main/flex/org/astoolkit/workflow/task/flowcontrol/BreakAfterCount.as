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

	public class BreakAfterCount extends BaseTask
	{

		private var _currentCount : uint = 0;

		private var _lastParentThread : uint;

		public var count : uint = 0;

		override public function begin() : void
		{
			super.begin();
			_currentCount++;

			if( count == _currentCount )
			{
				var aParent : IWorkflowElement = parent;

				while( !( aParent is ITasksGroup ) )
					aParent = aParent.parent;
				ITasksGroup( aParent ).abort();
				return;
			}
			complete();
		}

		override public function prepare() : void
		{
			super.prepare();

			if( _lastParentThread != _parent.currentThread )
			{
				_lastParentThread = _parent.currentThread;
				_currentCount = 0;
			}
		}
	}
}
