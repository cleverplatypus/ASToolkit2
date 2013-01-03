package org.astoolkit.workflow.api
{

	public interface IDeferrableProcess
	{
		function addDeferredProcessWatcher( inWatcher : Function ) : void;
		function isProcessDeferred() : Boolean;
	}
}
