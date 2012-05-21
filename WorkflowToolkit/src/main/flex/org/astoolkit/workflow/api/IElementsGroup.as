package org.astoolkit.workflow.api
{
	import org.astoolkit.workflow.core.Insert;

	public interface IElementsGroup extends IWorkflowElement
	{
		
		/**
		 * a list of <code>Insert</code> objects to perform
		 * runtime modification of groups.
		 * 
		 * @see org.astoolkit.workflow.core.Insert
		 */
		function set insert( inInserts : Vector.<Insert> ) : void;
		function get insert() : Vector.<Insert>;

		/**
		 * the declared tasks
		 */
		function get children() : Vector.<IWorkflowElement>;
		function set children( inChildren : Vector.<IWorkflowElement> ) : void;
		
	}
}