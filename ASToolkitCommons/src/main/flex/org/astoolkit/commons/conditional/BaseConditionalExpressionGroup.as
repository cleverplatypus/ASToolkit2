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

	public class BaseConditionalExpressionGroup extends BaseConditionalExpression implements IConditionalExpressionGroup
	{
		protected var _children : Vector.<IConditionalExpression>;

		override public function get isAsync() : Boolean
		{
			return hasAsyncChild( children );
		}

		public function get children() : Vector.<IConditionalExpression>
		{
			return _children;
		}

		public function set children( inValue : Vector.<IConditionalExpression> ) : void
		{
			_children = inValue;

			setupChildren();
		}

		override public function evaluate( inComparisonValue : * = undefined ) : Object
		{
			_lastResult = undefined;
			return _lastResult;
		}

		override public function invalidate() : void
		{
			super.invalidate();

			if( _children )
			{
				for each( var child : IConditionalExpression in _children )
					child.invalidate();
			}
		}

		override public function set resolver( inValue : IExpressionResolver ) : void
		{
			super.resolver = inValue;
			setupChildren();
		}


		private function hasAsyncChild( inChildren : Vector.<IConditionalExpression> ) : Boolean
		{
			var child : IConditionalExpression;

			for each( child in inChildren )
			{
				if( !( child is IConditionalExpressionGroup ) && child.isAsync )
					return true
			}

			for each( child in inChildren )
			{
				if( child is IConditionalExpressionGroup )
				{
					if( child.isAsync )
						return true;
				}
			}
			return false;
		}

		/**
		 * @private
		 */
		private function setupChildren() : void
		{
			if( _children )
			{
				for each( var child : IConditionalExpression in _children )
				{
					child.resolver = _resolver;
					child.parent = this;
				}
			}
		}
	}
}
