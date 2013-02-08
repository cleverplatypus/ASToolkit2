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

		public function set taskWatcherPriority( inValue :int) : void
		{
			_taskWatcherPriority = inValue;
		}

		public function afterTaskBegin( inTask : IWorkflowTask ) : void
		{
			if( afterTaskBeginWatcher != null )
				afterTaskBeginWatcher( inTask );
		}

		public function afterTaskDataSet( inTask : IWorkflowTask ) : void
		{
			if( taskDataSetWatcher != null )
				taskDataSetWatcher( inTask );
		}

		public function beforeTaskBegin( inTask : IWorkflowTask ) : void
		{
			if( beforeTaskBeginWatcher != null )
				beforeTaskBeginWatcher( inTask );
		}

		public function onBeforeContextUnbond( inElement : IWorkflowElement ) : void
		{

		}

		public function onContextBond( inElement : IWorkflowElement ) : void
		{
			if( contextBoundWatcher != null )
				contextBoundWatcher( inElement );
		}

		public function onTaskAbort( inTask : IWorkflowTask ) : void
		{
		}

		public function onTaskBegin( inTask : IWorkflowTask ) : void
		{
			if( taskBeginWatcher is Function )
				taskBeginWatcher( inTask );
		}

		public function onTaskComplete( inTask : IWorkflowTask ) : void
		{
			if( taskCompleteWatcher is Function )
				taskCompleteWatcher( inTask );
		}

		public function onTaskDeferExecution( inTask : IWorkflowTask ) : void
		{
			if( taskDeferExecutionWatcher is Function )
				taskDeferExecutionWatcher( inTask );
		}

		public function onDeferredTaskResume( inTask : IWorkflowTask ) : void
		{
			if( deferredTaskResumeWatcher is Function )
				deferredTaskResumeWatcher( inTask );
		}

		public function onTaskExitStatus( inTask : IWorkflowTask, inStatus : ExitStatus ) : void
		{
		}

		public function onTaskFail( inTask : IWorkflowTask, inMessage : String ) : void
		{
		}

		public function onTaskInitialize( inTask : IWorkflowTask ) : void
		{
		}

		public function onTaskPrepare(inTask:IWorkflowTask) : void
		{
			if( taskPreparedWatcher is Function )
				taskPreparedWatcher( inTask );

		}

		public function onTaskSuspend( inTask : IWorkflowTask ) : void
		{
		}

		public function onWorkflowCheckingNextTask( inWorkflow : ITasksGroup, inPipelineData : Object ) : void
		{
		}

		public function onTaskProgress(inTask:IWorkflowTask) : void
		{
			// TODO Auto Generated method stub

		}

		public function onTaskResume(inTask:IWorkflowTask) : void
		{
			// TODO Auto Generated method stub

		}

	}
}
