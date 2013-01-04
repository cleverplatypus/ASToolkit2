package org.astoolkit.workflow.api
{

	public interface IRuntimePropertyOverrideGroup extends ITasksGroup
	{
		function propertyShouldOverride( inProperty : String ) : Boolean;
	}
}
