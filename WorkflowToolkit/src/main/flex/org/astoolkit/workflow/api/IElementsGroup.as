package org.astoolkit.workflow.api
{

	import org.astoolkit.workflow.core.Insert;

	public interface IElementsGroup extends IWorkflowElement
	{
		/**
		 * the declared elements
		 */
		function get children() : Vector.<IWorkflowElement>;
		function set children( inChildren : Vector.<IWorkflowElement> ) : void;
		function get insert() : Vector.<Insert>;
		/**
		 * a list of <code>Insert</code> objects to perform
		 * runtime modification of groups.
		 *
		 * @see org.astoolkit.workflow.core.Insert
		 */
		function set insert( inInserts : Vector.<Insert> ) : void;
	}
}
