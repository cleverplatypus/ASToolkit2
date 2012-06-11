package org.astoolkit.workflow.task.api
{

	[Bindable]
	[Template]
	/**
	 * Template for a task that shows an object's structure
	 * optionally suspending the workflow execution.
	 * <p>Implementations could show a window with
	 * the object's outline tree or dump the provided data
	 * in any format for auditing.</p>
	 */
	public interface IInspectObject
	{
		function set object( inValue : Object ) : void;
		function set pause( inValue : Boolean ) : void;
	}
}
