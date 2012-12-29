package org.astoolkit.commons.collection.api
{

	import mx.core.IFactory;
	import org.astoolkit.commons.factory.api.IPooledFactory;

	public interface IIteratorFactory extends IPooledFactory
	{
		function iteratorForSource( inSource : Object, inProperties : Object = null ) : IIterator;
	}
}
