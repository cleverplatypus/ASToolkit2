package org.astoolkit.workflow.api
{
	import org.astoolkit.commons.collection.api.IIteratorFactory;
	import org.astoolkit.commons.io.filter.api.IIOFilterRegistry;

	public interface IContextConfig
	{
		function get inputFilterRegistry() : IIOFilterRegistry;
		function set inputFilterRegistry( inValue : IIOFilterRegistry ) : void;
		
		function get iteratorFactory() : IIteratorFactory;
		function set iteratorFactory( inValue : IIteratorFactory ) : void;
		
		function get propertyOverrideRule() : IPropertyOverrideRule;
		function set propertyOverrideRule( inValue : IPropertyOverrideRule ) : void;
		
		function init() : void;
	}
}