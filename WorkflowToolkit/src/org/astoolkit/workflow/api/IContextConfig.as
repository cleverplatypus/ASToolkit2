package org.astoolkit.workflow.api
{
	import org.astoolkit.commons.collection.api.IIteratorFactory;
	import org.astoolkit.commons.io.filter.api.IIOFilterRegistry;

	/**
	 * Contract for in IWorkflowContext configuration object.
	 */ 
	public interface IContextConfig
	{
		/**
		 * an instance of <code>IIOFilterRegistry</code> providing
		 * access to all the registered IIOFilter implementations
		 * made available to the <code>IWorkflowContext</code>
		 */
		function get inputFilterRegistry() : IIOFilterRegistry;
		function set inputFilterRegistry( inValue : IIOFilterRegistry ) : void;
		
		/**
		 * an instance of <code>IIteratorFactory</code> providing
		 * access to all the registered <code>IIterator</code> implementations
		 * made available to the <code>IWorkflowContext</code>
		 */
		function get iteratorFactory() : IIteratorFactory;
		function set iteratorFactory( inValue : IIteratorFactory ) : void;
		
		/**
		 * an instance of <code>IPropertyOverrideRule</code> providing
		 * the rule for properties override.
		 * 
		 * @see org.astoolkit.workflow.core.Group
		 */
		function get propertyOverrideRule() : IPropertyOverrideRule;
		function set propertyOverrideRule( inValue : IPropertyOverrideRule ) : void;
		
		/**
		 * called by the owner <code>IWorkflowContext</code> after
		 * setting the config's properties.
		 */
		function init() : void;
	}
}