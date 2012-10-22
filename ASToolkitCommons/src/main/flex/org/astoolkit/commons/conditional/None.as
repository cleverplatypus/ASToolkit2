package org.astoolkit.commons.conditional
{

	public class None extends Any
	{
		override public function evaluate( inComparisonValue : * = undefined ) : Object
		{
			return !super.evaluate( inComparisonValue );
		}
	}
}
