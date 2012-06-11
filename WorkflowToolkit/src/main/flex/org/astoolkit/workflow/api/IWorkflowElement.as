package org.astoolkit.workflow.api
{
	
	import flash.events.IEventDispatcher;
	import mx.core.IMXMLObject;
	import org.astoolkit.commons.collection.api.IIterator;
	
	public interface IWorkflowElement extends IEventDispatcher, IMXMLObject
	{
		/**
		 * called when the root workflow completes.
		 * <p>Implementations should override this method to release
		 * any allocated resource.</p>
		 */
		function cleanUp() : void;
		/**
		 * the workflow context for this element. Set by the wrapping workflow.
		 */
		function get context() : IWorkflowContext;
		function set context( inContext : IWorkflowContext ) : void;
		/**
		 * @private
		 *
		 * the wrapping workflow's iterator if any
		 */
		function set currentIterator( inValue : IIterator ) : void;
		function set delegate( inValue : IWorkflowDelegate ) : void;
		/**
		 * an optional human readable description for this element.
		 * <p>If not defined, a string containing the branch this element
		 * belongs to is generated</p>
		 */
		function get description() : String;
		function set description( inName : String ) : void;
		/**
		 * the class defined as MXML document this element belongs to
		 */
		function get document() : Object;
		/**
		 * if false this element will be skipped
		 */
		[Inspectable( defaultValue="true", type="Boolean" )]
		function get enabled() : Boolean;
		function set enabled( inEnabled : Boolean ) : void;
		/**
		 * the MXML id string
		 */
		function get id() : String;
		/**
		 * called by parent workflow when root workflow begins.
		 * <p>Override this method in custom elements to allocate
		 * resources which lifetime spans the root workflow's lifetime.</p>
		 * Do not call this method directly.
		 */
		function initialize() : void;
		/**
		 * the wrapping group. Null for root element
		 */
		function get parent() : IElementsGroup;
		function set parent( inParent : IElementsGroup ) : void;
		/**
		 * called by parent workflow before begin.
		 * <p>If this task has state, override this method and
		 * reset any value for next invocation.</p>
		 */
		function prepare() : void;
	}
}
