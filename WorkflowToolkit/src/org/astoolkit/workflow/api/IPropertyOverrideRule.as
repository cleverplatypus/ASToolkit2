package org.astoolkit.workflow.api
{
	public interface IPropertyOverrideRule
	{
		function shouldOverride( inProperty : String, inTarget : IWorkflowElement, inParent : IElementsGroup ) : Boolean;
		
	}
}