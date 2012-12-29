package org.astoolkit.workflow.internals
{

	import org.astoolkit.workflow.api.ITaskLiveCycleWatcher;
	import org.astoolkit.workflow.api.ITasksFlow;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.core.ExitStatus;

	//TODO: finish implementation
	public final class DynamicTaskLiveCycleWatcher implements ITaskLiveCycleWatcher
	{
		private var _taskWatcherPriority : int;
		
		public function get taskWatcherPriority():int
		{
			return _taskWatcherPriority;
		}

		public function set taskWatcherPriority(value:int):void
		{
			_taskWatcherPriority = value;
		}

		public var afterTaskBeginWatcher : Function;

		public var beforeTaskBeginWatcher : Function;
		
		public var contextBoundWatcher : Function;
		
		public var taskPreparedWatcher : Function;

		public var taskDataSetWatcher : Function;

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

		public function onContextBond( inElement : IWorkflowElement ) : void
		{
			if( contextBoundWatcher != null )
				contextBoundWatcher( inElement );
		}

		public function onBeforeContextUnbond( inElement : IWorkflowElement ) : void
		{
			
		}
		
		
		public function onTaskAbort( inTask : IWorkflowTask ) : void
		{
		}

		public function onTaskBegin( inTask : IWorkflowTask ) : void
		{
		}

		public function onTaskComplete( inTask : IWorkflowTask ) : void
		{
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

		public function onTaskSuspend( inTask : IWorkflowTask ) : void
		{
		}

		public function onWorkflowCheckingNextTask( inWorkflow : ITasksFlow, inPipelineData : Object ) : void
		{
		}
		
		public function onTaskPrepared(inTask:IWorkflowTask):void
		{
			if( taskPreparedWatcher is Function )
				taskPreparedWatcher( inTask );
			
		}
		
	}
}
