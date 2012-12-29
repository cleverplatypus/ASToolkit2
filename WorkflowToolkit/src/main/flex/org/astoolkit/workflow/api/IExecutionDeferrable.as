package org.astoolkit.workflow.api
{

	import mx.rpc.IResponder;

	public interface IExecutionDeferrable
	{
		function addDeferredExecutionResponder( inResponser : IResponder ) : void;
		function isExecutionDeferred() : Boolean;
	}
}
