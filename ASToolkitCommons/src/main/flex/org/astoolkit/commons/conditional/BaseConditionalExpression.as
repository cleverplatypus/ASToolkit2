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
package org.astoolkit.commons.conditional
{

	import org.astoolkit.commons.conditional.api.IConditionalExpression;
	import org.astoolkit.commons.conditional.api.IConditionalExpressionGroup;
	import org.astoolkit.commons.conditional.api.IExpressionResolver;

	public class BaseConditionalExpression implements IConditionalExpression
	{
		protected var _lastResult : *;

		protected var _parent : IConditionalExpressionGroup;

		protected var _resolver : IExpressionResolver;

		public function set delegate(value:Function):void
		{
			_delegate = value;
		}

		protected var _delegate : Function;
		
		public function get async() : Boolean
		{
			return false;
		}

		public function clearResult() : void
		{
			_lastResult = undefined;

		}

		public function evaluate( inComparisonValue : * = undefined ) : Object
		{
			_lastResult = undefined;
			return _lastResult;
		}

		public function initialized( document : Object, id : String ) : void
		{
			// TODO Auto Generated method stub

		}


		public function invalidate() : void
		{
			// TODO Auto Generated method stub

		}

		public function get lastResult() : *
		{
			return _lastResult;
		}


		public function get parent() : IConditionalExpressionGroup
		{
			return _parent;
		}

		public function set parent( value : IConditionalExpressionGroup ) : void
		{
			_parent = value;
		}

		public function set resolver( inValue : IExpressionResolver ) : void
		{
			_resolver = inValue;
		}

		public function get root() : IConditionalExpressionGroup
		{
			var exp : IConditionalExpression = this;

			while( exp.parent )
				exp = exp.parent;
			return exp as IConditionalExpressionGroup;
		}
		
		

	}
}
