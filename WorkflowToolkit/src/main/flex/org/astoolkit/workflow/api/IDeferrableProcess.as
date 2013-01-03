package org.astoolkit.workflow.api
{

	import mx.rpc.IResponder;
	import org.astoolkit.workflow.task.flowcontrol.IDeferrableProcessWatcher;

	public interface IDeferrableProcess
	{
		function addDeferredProcessWatcher( inWatcher : Function ) : void;
		function isProcessDeferred() : Boolean;
	}
}
