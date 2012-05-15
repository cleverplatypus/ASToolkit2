package org.astoolkit.workflow.api
{
	import org.astoolkit.commons.collection.api.IIterator;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.IMXMLObject;

	public interface IWorkflowElement extends IEventDispatcher, IMXMLObject
	{

		/**
		 * a description for this element.
		 */
		function get description() : String;
		function set description( inName : String ) : void;

		/**
		 * if false this element will be skipped
		 */
		[Inspectable(defaultValue="true", type="Boolean")]
		function get enabled() : Boolean;
		function set enabled( inEnabled : Boolean ) : void;
		
		/**
		 * called by parent workflow when root workflow begins
		 * Users should not call this method directly.
		 */
		function initialize() : void;
		
		/**
		 * called by parent workflow before begin.
		 * If this task has state, this is the place to put code to 
		 * reset any value for next invocation.
		 * A "prepare" event must be dispatched first. 
		 * Listeners might perform dependency injection at this point.
		 */
		function prepare() : void;

		/**
		 * called when the root workflow completes.
		 * implementations should release any allocated resource
		 * or listener used during the whole task's lifetime
		 */
		function cleanUp() : void;

		/**
		 * the wrapping group. Null for root element 
		 */
		function get parent() : IElementsGroup;
		function set parent( inParent : IElementsGroup ) : void;

		function get context() : IWorkflowContext;
		function set context( inContext : IWorkflowContext ) : void;
		
		function set currentIterator( inValue : IIterator ) : void;

		function set delegate( inValue : IWorkflowDelegate ) : void;

		function get id() : String;
		
		function get document() : Object;

	}
}