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
package org.astoolkit.workflow.inputfilter
{
	import flash.utils.getQualifiedClassName;
	
	import org.astoolkit.commons.io.transform.FunctionReferenceDataTransform;
	import org.astoolkit.commons.io.transform.ObjectPropertyChainDataTransform;
	import org.astoolkit.commons.io.transform.api.*;


	public class DefaultTaskInputFilterRegistry implements IIODataTransformRegistry
	{
		private var _filters : Vector.<IIODataTransform>;
		private var _filtersBySelector : Object;
		
		public function DefaultTaskInputFilterRegistry()
		{
			_filters = new Vector.<IIODataTransform>();
			registerTransformer( ObjectPropertyChainDataTransform );
			registerTransformer( FunctionReferenceDataTransform );
		}
		
		public function getTransformer( inData : Object, inExpression : Object ) : IIODataTransform
		{
			for each( var f : IIODataTransform in _filters )
			{
				for each( var dataType : Class in f.supportedDataTypes )
				{
					if( inData is dataType )
					{
						for each( var filterType : Class in f.supportedExpressionTypes )
						{
							if( inExpression is filterType && f.isValidExpression( inExpression ) )
							{
								return f;
							}
						}
					}
				}
			}
			return null;
		}

		private function sortFilters( inFilterA : IIODataTransform, inFilterB : IIODataTransform  ) : int
		{
			if( inFilterA.priority < inFilterB.priority )
				return 1;
			else if( inFilterA.priority > inFilterB.priority )
				return -1;
			return 0;
		}
		
		public function registerTransformer( inObject : Object ) : void
		{
			var o : Object = inObject is Class ? new inObject() : inObject;
			if( !( o is IIODataTransform ) )
				throw new Error( "Attempt to register unrelated class " + 
					getQualifiedClassName( o ) + " as IIODataTransform" );
			_filters.push( o as IIODataTransform );
			_filters = _filters.sort( sortFilters );
		}
		
	}
}