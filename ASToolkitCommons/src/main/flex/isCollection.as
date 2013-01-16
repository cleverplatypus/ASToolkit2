package
{

	import mx.collections.IList;

	public function isCollection( inSource : Object ) : Boolean
	{
		return isVector( inSource ) || inSource is Array || inSource is IList || inSource is XMLList;
	}
}
