package
{

	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;

	public function isVector( inSource : Object, inSubtype : Class = null ) : Boolean
	{
		var out : Boolean;
		out = getQualifiedClassName( inSource ).match( /__AS3__\.vec\:\:Vector\.\</ ) != null;
		return out;
	}
}
