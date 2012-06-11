package org.astoolkit.commons.mapping
{

	public interface IPropertiesMapperFactory
	{
		function object(
		inTarget : Object,
			inMapping : Object,
			inStrict : Boolean = true ) : IPropertiesMapper;
		function property(
		inTarget : Object,
			inPropertyName : String ) : IPropertiesMapper;
	}
}
