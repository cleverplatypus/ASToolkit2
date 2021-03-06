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
	 * function with signature
	 * <code>function( inData : Object, inTarget : Object ) : Object</code>
	 */
	public class FunctionReferenceDataTransform extends BaseDataTransformer
	{

		public var functionName : String;

		public var transformFunction : Function;

		/**
		 * @private
		 */
		override public function isValidExpression( inExpression : Object ) : Boolean
		{
			return inExpression is Function;
		}

		/**
		 * @private
		 */
		override public function get priority() : int
		{
			return -100;
		}

		/**
		 * @private
		 */
		override public function get supportedDataTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( Object, null );
			return out;
		}

		/**
		 * @private
		 */
		override public function get supportedExpressionTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( Function );
			return out;
		}

		/**
		 * @private
		 */
		override public function transform( inData : Object, inExpression : Object, inTarget : Object = null ) : Object
		{
			if( functionName )
				return TransformUtil.call( functionName )( inData, inTarget );

			if( transformFunction != null )
				return transformFunction( inData, inTarget );
			else
				return ( inExpression as Function )( inData, inTarget );
		}
	}
}
