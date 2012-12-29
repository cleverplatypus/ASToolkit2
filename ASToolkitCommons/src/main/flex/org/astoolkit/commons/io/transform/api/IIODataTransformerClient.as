package org.astoolkit.commons.io.transform.api
{
	public interface IIODataTransformerClient
	{
		function set dataTransformerRegistry( inRegistry : IIODataTransformerRegistry ) : void;
		/**
		 * a filter for this task's pipeline data.<br><br>
		 */
		function set inputFilter( inValue : Object ) : void;
	}
}