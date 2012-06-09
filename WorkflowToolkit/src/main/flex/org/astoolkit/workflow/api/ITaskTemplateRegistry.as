package org.astoolkit.workflow.api
{
	public interface ITaskTemplateRegistry
	{
		function registerImplementation( inImplementation : Object ) : void;
		function getImplementation( inTemplate : ITaskTemplate ) : IWorkflowTask;
		function releaseImplementation( inImplementation : IWorkflowTask ) : void;
	}
}