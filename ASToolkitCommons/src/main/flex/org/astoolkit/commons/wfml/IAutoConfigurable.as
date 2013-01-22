package org.astoolkit.commons.wfml
{
	import mx.core.IMXMLObject;

	public interface IAutoConfigurable extends IMXMLObject
	{
		function set autoConfigChildren( inValue : Array ) : void;
	}
}