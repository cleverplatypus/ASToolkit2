package org.astoolkit.workflow.api
{
	
	public interface ITaskTemplateRegistry
	{
		function getImplementation( inTemplate : ITaskTemplate ) : IWorkflowTask;
		function registerImplementation( inImplementation : Object ) : void;
		function releaseImplementation( inImplementation : IWorkflowTask ) : void;
	}
}
