package org.astoolkit.workflow.api
{
	
	import org.astoolkit.workflow.core.ExitStatus;
	
	public interface ITaskLiveCycleWatcher
	{
		function afterTaskBegin( inTask : IWorkflowTask ) : void;
		function afterTaskDataSet( inTask : IWorkflowTask ) : void
		function beforeTaskBegin( inTask : IWorkflowTask ) : void;
		function onContextBound( inTask : IWorkflowTask ) : void;
		function onTaskAbort( inTask : IWorkflowTask ) : void;
		function onTaskBegin( inTask : IWorkflowTask ) : void;
		function onTaskComplete( inTask : IWorkflowTask ) : void;
		function onTaskExitStatus( inTask : IWorkflowTask, inStatus : ExitStatus ) : void;
		function onTaskFail( inTask : IWorkflowTask ) : void;
		function onTaskInitialize( inTask : IWorkflowTask ) : void;
		function onTaskSuspend( inTask : IWorkflowTask ) : void;
		function onWorkflowCheckingNextTask(
		inWorkflow : IWorkflow,
			inPipelineData : Object ) : void;
	}
}
