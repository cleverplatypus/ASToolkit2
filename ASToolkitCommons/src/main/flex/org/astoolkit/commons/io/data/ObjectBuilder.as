package org.astoolkit.commons.io.data
{

	[DefaultProperty("autoConfigChildren")]
	public class ObjectBuilder extends AbstractBuilder
	{
		public function set type( inValue : Class ) : void
		{
			_providedType = inValue;
		}
	}
}
