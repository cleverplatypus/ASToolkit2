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
	 * input filter that expects <code>inExpression</code> to be a
	 * <code>RegExp</code> object or an array of strings with
	 * the first element being the regexp expression in the form
	 * /REGEXP/OPTIONS,
	 * an optional second element containing the output type,
	 * "all" = the match return array or an int <em>n</em>
	 * representing the index of the desired output array element.
	 */
	public class RegExpDataTransform implements IIODataTransformer
	{
		public function isValidExpression( inExpression : Object ) : Boolean
		{
			return inExpression is RegExp || inExpression is REConfig;
		}

		public function get priority() : int
		{
			return 0;
		}

		public function get supportedDataTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( String );
			return out;
		}

		public function get supportedExpressionTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( RegExp );
			out.push( REConfig );
			return out;
		}

		public function transform(
			inData : Object,
			inExpression : Object,
			inTarget : Object = null ) : Object
		{
			if( !isValidExpression( inExpression ) )
				throw new Error( "Invalid transform expression" );
			var re : RegExp = inExpression is RegExp ?
				inExpression as RegExp :
				( inExpression as REConfig ).regexp;
			var outIndex : int = inExpression is RegExp ?
				-1 : ( inExpression as REConfig ).outputIndex;
			var out : Array = String( inData ).match( re );

			if( outIndex == -1 )
				return out;
			else
				return out[ outIndex ];
		}
	}
}
