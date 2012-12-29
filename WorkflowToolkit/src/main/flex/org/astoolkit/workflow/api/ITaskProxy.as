package org.astoolkit.workflow.api
{

	public interface ITaskProxy extends IWorkflowElement
	{
		function getTask() : IWorkflowTask;
	}
}
