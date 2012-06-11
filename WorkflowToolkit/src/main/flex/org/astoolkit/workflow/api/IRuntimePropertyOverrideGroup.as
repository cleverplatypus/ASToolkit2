package org.astoolkit.workflow.api
{

	public interface IRuntimePropertyOverrideGroup extends IElementsGroup
	{
		function propertyShouldOverride( inProperty : String ) : Boolean;
	}
}
