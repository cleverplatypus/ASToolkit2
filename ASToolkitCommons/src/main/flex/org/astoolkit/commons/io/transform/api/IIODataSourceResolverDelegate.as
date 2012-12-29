package org.astoolkit.commons.io.transform.api
{
	public interface IIODataSourceResolverDelegate
	{
		function resolveDataSource( inSourceDescriptor : Object, inNextDelegate : IIODataSourceResolverDelegate ) : *; 
	}
}