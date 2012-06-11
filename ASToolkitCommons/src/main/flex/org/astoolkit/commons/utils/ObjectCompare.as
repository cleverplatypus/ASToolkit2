package org.astoolkit.commons.utils
{
	
	public final class ObjectCompare
	{
		public static function compare( inA : *, inB : * ) : int
		{
			if(inA == inB)
				return 0;
			
			if(inA > inB)
				return 1;
			return -1;
		}
	}
}
