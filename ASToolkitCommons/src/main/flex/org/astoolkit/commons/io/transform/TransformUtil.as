/*

Copyright 2009 Nicola Dal Pont

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Version 2.x

*/
package org.astoolkit.commons.io.transform
{

	import org.astoolkit.commons.io.transform.api.IIODataTransformer;

	public final class TransformUtil
	{
		public static function call( inFunctionName : String, ... inParams ) : Function
		{
			var out : * =
				function( inData : Object, inTarget : Object ) : Object
				{
					if( inData is XML || inData is XMLList )
						inData = new XMLWrapper( inData );
					return inData[ inFunctionName ].apply( inData, inParams );
				};
			return out as Function;
		}

		public static function functionTransformer( inFunctionName : String, ... inParams ) : IIODataTransformer
		{
			var out : FunctionReferenceDataTransform = new FunctionReferenceDataTransform();
			out.transformFunction =
				function( inData : Object, inTarget : Object ) : Object
				{
					if( inData is XML || inData is XMLList )
						inData = new XMLWrapper( inData );
					return inData[ inFunctionName ].apply( inData, inParams );
				};
			return out;
		}
	}
}

class XMLWrapper
{
	public function XMLWrapper( inXML : * )
	{
		_xml = inXML;
	}

	protected var _xml : *;

	public function attribute( a : * ) : *
	{
		return _xml.attribute( a );
	}

	public function attributes() : *
	{
		return _xml.attributes();
	}

	public function child( a : * ) : *
	{
		return _xml.child( a );
	}

	public function childIndex() : *
	{
		return _xml.childIndex();
	}

	public function children() : *
	{
		return _xml.children();
	}

	public function copy() : *
	{
		return _xml.copy();
	}

	public function descendants( a : * ) : *
	{
		return _xml.descendants( a );
	}

	public function elements( a : * ) : *
	{
		return _xml.elements( a );
	}

	public function inScopeNamespaces() : *
	{
		return _xml.inScopeNamespaces();
	}

	public function name() : *
	{
		return _xml.name();
	}

	public function nodeKind() : *
	{
		return _xml.nodeKind();
	}

	public function parent() : *
	{
		return _xml.parent();
	}

	public function replace( a : *, b : * ) : *
	{
		return _xml.replace( a, b );
	}

	public function toXMLString() : *
	{
		return _xml.toXMLString();
	}
}
