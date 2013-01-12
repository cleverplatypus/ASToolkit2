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

		public function onTaskFail( inTask : IWorkflowTask ) : void
		{
		}

		public function onTaskInitialize( inTask : IWorkflowTask ) : void
		{
		}

		public function onTaskPrepared(inTask:IWorkflowTask) : void
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
	}
}
