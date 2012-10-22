package org.astoolkit.workflow.internals
{

	import org.astoolkit.workflow.api.ITaskLiveCycleWatcher;
	import org.astoolkit.workflow.api.IWorkflow;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.core.ExitStatus;

	public final class DynamicTaskLiveCycleWatcher implements ITaskLiveCycleWatcher
	{
		public var afterTaskBeginWatcher : Function;

		public var beforeTaskBeginWatcher : Function;

		public function afterTaskBegin( inTask : IWorkflowTask ) : void
		{
			if( afterTaskBeginWatcher != null )
				afterTaskBeginWatcher( inTask );
		}

		public function afterTaskDataSet( inTask : IWorkflowTask ) : void
		{
		}

		public function beforeTaskBegin( inTask : IWorkflowTask ) : void
		{
			if( beforeTaskBeginWatcher != null )
				beforeTaskBeginWatcher( inTask );
		}

		public function onContextBound( inTask : IWorkflowTask ) : void
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

		public function onWorkflowCheckingNextTask( inWorkflow : IWorkflow, inPipelineData : Object ) : void
		{
		}
	}
}
