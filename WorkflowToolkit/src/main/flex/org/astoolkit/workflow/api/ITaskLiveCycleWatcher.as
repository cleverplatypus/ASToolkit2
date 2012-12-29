package org.astoolkit.workflow.api
{

	import org.astoolkit.workflow.core.ExitStatus;

	public interface ITaskLiveCycleWatcher
	{
		function set taskWatcherPriority( inValue : int ) : void;
		function get taskWatcherPriority() : int;
		function afterTaskBegin( inTask : IWorkflowTask ) : void;
		function afterTaskDataSet( inTask : IWorkflowTask ) : void
		function beforeTaskBegin( inTask : IWorkflowTask ) : void;
		function onContextBond( inElement : IWorkflowElement ) : void;
		function onBeforeContextUnbond( inTask : IWorkflowElement ) : void;
		function onTaskAbort( inTask : IWorkflowTask ) : void;
		function onTaskBegin( inTask : IWorkflowTask ) : void;
		function onTaskComplete( inTask : IWorkflowTask ) : void;
		function onTaskPrepared( inTask : IWorkflowTask ) : void;
		function onTaskExitStatus( inTask : IWorkflowTask, inStatus : ExitStatus ) : void;
		function onTaskFail( inTask : IWorkflowTask ) : void;
		function onTaskInitialize( inTask : IWorkflowTask ) : void;
		function onTaskSuspend( inTask : IWorkflowTask ) : void;
		function onWorkflowCheckingNextTask(
		inWorkflow : ITasksFlow,
			inPipelineData : Object ) : void;
	}
}
