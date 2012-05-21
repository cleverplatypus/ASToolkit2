package org.astoolkit.commons.collection.api
{
	import org.astoolkit.commons.factory.IPooledFactory;
	
	import mx.core.IFactory;
	
	public interface IIteratorFactory extends IPooledFactory
	{
		function iteratorForSource( inSource : Object, inProperties : Object = null ) : IIterator;
	}
}