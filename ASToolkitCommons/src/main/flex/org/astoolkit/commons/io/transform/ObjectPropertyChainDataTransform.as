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
	
	/**
	 * Input filter to drill into objects using the dot notation.
	 * <p>"." will return the filtered object itself.</p>
	 */
	public class ObjectPropertyChainDataTransform implements IIODataTransformer
	{
		/**
		 * @private
		 */
		public function isValidExpression( inExpression : Object ) : Boolean
		{
			var exp : String = inExpression as String;
			return exp != null &&
				(exp == "." || exp.match( /^\w+(\.\w+)*$/ ));
		}
		
		/**
		 * @private
		 */
		public function get priority() : int
		{
			return -100;
		}
		
		/**
		 * @private
		 */
		public function get supportedDataTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( Object );
			return out;
		}
		
		/**
		 * @private
		 */
		public function get supportedExpressionTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( String );
			return out;
		}
		
		/**
		 * returns the value of <code>inData</code>'s property chain <code>inExpression</code>
		 */
		public function transform( inData : Object, inExpression : Object, inTarget : Object = null ) : Object
		{
			if(inData == null)
				return null;
			
			if(inExpression == ".")
				return inData;
			var val : Object = inData;
			
			for each(var k : String in inExpression.split( "." ))
			{
				val = val[k];
			}
			return val;
		}
	}
}
