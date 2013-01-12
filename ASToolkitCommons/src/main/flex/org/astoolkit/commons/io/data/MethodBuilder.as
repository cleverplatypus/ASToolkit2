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
package org.astoolkit.commons.io.data
{

	import org.astoolkit.commons.conditional.api.IExpressionResolver;

	[DefaultProperty("autoConfigChildren")]
	public class MethodBuilder extends AbstractBuilder
	{

		public static function parse( inString : String ) : MethodBuilder
		{
			var out : MethodBuilder = new MethodBuilder();
			return out;
		}

		private var _name : String;

		private var _target : Object;

		/**
		 * alias setter for _expressionResolvers property. For declaration clarity.
		 */
		public function set arguments( inValue : Vector.<IExpressionResolver> ) : void
		{
			_expressionResolvers = inValue;
		}

		public function set name( inValue : String ) : void
		{
			_name = inValue;
		}

		public function set target( inValue : Object ) : void
		{
			_target = inValue;
		}

		override public function getData() : *
		{
			var out : Function;
			//TODO: implement
			return out as Function; //casting to prevent compiler warning
		}
	}
}
