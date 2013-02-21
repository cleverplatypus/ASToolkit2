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
package org.astoolkit.workflow.internals
{

	import org.astoolkit.workflow.api.ITaskLiveCycleWatcher;
	import org.astoolkit.workflow.api.ITasksGroup;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.constant.TaskPhase;
	import org.astoolkit.workflow.core.ExitStatus;

	//TODO: finish implementation
	public final class DynamicTaskLiveCycleWatcher implements ITaskLiveCycleWatcher
	{
		private var _taskWatcherPriority : int;

		public var afterTaskBeginWatcher : Function;

		public var beforeTaskBeginWatcher : Function;

		public var contextBoundWatcher : Function;

		public var deferredTaskResumeWatcher : Function;

		public var taskBeginWatcher : Function;

		public var taskCompleteWatcher : Function;

		public var taskDataSetWatcher : Function;

		public var taskDeferExecutionWatcher : Function;

		public var taskPreparedWatcher : Function;

		public function get taskWatcherPriority() : int
		{
			return _taskWatcherPriority;
		}

		public function set taskWatcherPriority( inValue : int ) : void
		{
			_taskWatcherPriority = inValue;
		}

		public function onTaskPhase( inTask : IWorkflowTask, inPhase : String, inData : * = undefined ) : void
		{
			if( inPhase == TaskPhase.PREPARED )
			{
				if( taskPreparedWatcher is Function )
					taskPreparedWatcher( inTask );
			}
			else if( inPhase == TaskPhase.RESUMED_DEFERRED_EXECUTION )
			{
				if( deferredTaskResumeWatcher is Function )
					deferredTaskResumeWatcher( inTask );

			}
			else if( inPhase == TaskPhase.AFTER_BEGIN )
			{
				if( afterTaskBeginWatcher != null )
					afterTaskBeginWatcher( inTask );

			}
			else if( inPhase == TaskPhase.DEFERRING_EXECUTION )
			{
				if( taskDeferExecutionWatcher is Function )
					taskDeferExecutionWatcher( inTask );
			}
			else if( inPhase == TaskPhase.COMPLETED )
			{
				if( taskCompleteWatcher is Function )
					taskCompleteWatcher( inTask );

			}
			else if( inPhase == TaskPhase.BEGUN )
			{
				if( taskBeginWatcher is Function )
					taskBeginWatcher( inTask );
			}
			else if( inPhase == TaskPhase.CONTEXT_BOND )
			{
				if( contextBoundWatcher != null )
					contextBoundWatcher( inTask, inData );
			}
			else if( inPhase == TaskPhase.BEFORE_BEGIN )
			{
				if( beforeTaskBeginWatcher != null )
					beforeTaskBeginWatcher( inTask );
			}
			else if( inPhase == TaskPhase.DATA_SET )
			{
				if( taskDataSetWatcher != null )
					taskDataSetWatcher( inTask );
			}
		}

	}
}
