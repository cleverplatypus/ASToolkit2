package org.astoolkit.workflow.api
{
	import org.astoolkit.workflow.core.ExitStatus;

	public interface IWorkflowDelegate
	{
		function onInitialize( inTask : IWorkflowTask ) : void;
		function onComplete( inTask : IWorkflowTask ) : void;
		function onPrepare( inTask : IWorkflowTask ) : void;
		function onBegin( inTask : IWorkflowTask ) : void;
		function onSuspend( inTask : IWorkflowTask ) : void;
		function onResume( inTask : IWorkflowTask ) : void;
		function onProgress( inTask : IWorkflowTask ) : void;
		function onFault( inTask : IWorkflowTask, inMessage : String ) : void;
		function onAbort( inTask : IWorkflowTask, inMessage : String ) : void;
		
	}
}