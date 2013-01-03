package org.astoolkit.workflow.api
{

	public interface ISwitchCase extends ITaskProxy
	{
		function get task() : IWorkflowTask;
		function get value() : *;
		function get values() : Array;
	}
}
