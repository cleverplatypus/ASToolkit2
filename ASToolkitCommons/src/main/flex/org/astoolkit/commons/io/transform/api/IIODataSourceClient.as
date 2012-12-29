package org.astoolkit.commons.io.transform.api
{
	public interface IIODataSourceClient
	{
		function set source( inValue : Object ) : void;
		function set sourceResolverDelegate( inValue : IIODataSourceResolverDelegate ) : void;
	}
}