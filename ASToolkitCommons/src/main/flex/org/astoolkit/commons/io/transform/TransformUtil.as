package org.astoolkit.commons.io.transform
{
	
	public final class TransformUtil
	{
		public static function call( inFunctionName : String, ... inParams ) : *
		{
			var out : * =  function( inData : Object, inTarget : Object ) : Object
			{
				if ( inData is XML || inData is XMLList )
					inData = new XMLWrapper( inData );
				return inData[ inFunctionName ].apply( inData, inParams );
			}
			return out;
		}
	}
}

class XMLWrapper
{
	protected var _xml : *;
	
	public function XMLWrapper( inXML : * )
	{
		_xml = inXML;
	}
	
	public function toXMLString() : *
	{
		return _xml.toXMLString();
	}
	
	public function name() : *
	{
		return _xml.name();
	}
	
	public function children() : *
	{
		return _xml.children();
	}
	
	public function attribute(  a : * ) : *
	{
		return _xml.attribute( a );
	}
	
	public function child(  a : * ) : *
	{
		return _xml.child( a );
	}
	
	public function attributes() : *
	{
		return _xml.attributes();
	}
	
	public function childIndex() : *
	{
		return _xml.childIndex();
	}
	
	public function copy() : *
	{
		return _xml.copy();
	}
	
	public function nodeKind() : *
	{
		return _xml.nodeKind();
	}
	
	public function parent() : *
	{
		return _xml.parent();
	}
	
	public function descendants( a : * ) : *
	{
		return _xml.descendants(a);
	}
	
	public function elements( a : * ) : *
	{
		return _xml.elements(a);
	}
	
	public function inScopeNamespaces() : *
	{
		return _xml.inScopeNamespaces();
	}
	
	public function replace( a : *, b : * ) : *
	{
		return _xml.replace( a, b );
	}
}