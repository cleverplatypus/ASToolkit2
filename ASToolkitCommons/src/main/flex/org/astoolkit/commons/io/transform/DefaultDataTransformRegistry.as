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

	import flash.utils.getQualifiedClassName;

	import org.astoolkit.commons.io.transform.api.*;

	public class DefaultDataTransformRegistry implements IIODataTransformerRegistry
	{
		public function DefaultDataTransformRegistry()
		{
			_transformers = new Vector.<IIODataTransformer>();
			registerTransformer( ObjectPropertyChainDataTransform );
			registerTransformer( FunctionReferenceDataTransform );
			registerTransformer( RegExpDataTransform );
		}

		private var _transformers : Vector.<IIODataTransformer>;

		private var _transformersBySelector : Object;

		public function getTransformer( inData : Object, inExpression : Object ) : IIODataTransformer
		{
			for each( var f : IIODataTransformer in _transformers )
			{
				for each( var dataType : Class in f.supportedDataTypes )
				{
					if( inData is dataType )
					{
						var expressions : Array =
							inExpression is Array ?
							inExpression as Array :
							[ inExpression ];

						for each( var expression : Object in expressions )
						{
							for each( var filterType : Class in f.supportedExpressionTypes )
							{
								if( !( expression is filterType ) || !f.isValidExpression( expression ) )
								{
									return null;
								}
							}
						}
						return f;
					}
				}
			}
			return null;
		}

		public function registerTransformer( inObject : Object ) : void
		{
			var o : Object = inObject is Class ? new inObject() : inObject;

			if( !( o is IIODataTransformer ) )
				throw new Error( "Attempt to register unrelated class " +
					getQualifiedClassName( o ) + " as IIODataTransform" );
			_transformers.push( o as IIODataTransformer );
			_transformers = _transformers.sort( sort );
		}

		private function sort( inFilterA : IIODataTransformer, inFilterB : IIODataTransformer ) : int
		{
			if( inFilterA.priority < inFilterB.priority )
				return 1;
			else if( inFilterA.priority > inFilterB.priority )
				return -1;
			return 0;
		}
	}
}
