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
package org.astoolkit.workflow.conditional
{

	import org.astoolkit.commons.conditional.BaseConditionalExpression;
	import org.astoolkit.commons.conditional.api.IConditionalExpression;
	import org.astoolkit.commons.conditional.api.IConditionalExpressionGroup;

	[DefaultProperty( "condition" )]
	public class WithVariable extends BaseConditionalWorkflowExpression
	{
		public var condition : IConditionalExpression;

		protected var _name : String;

		override public function evaluate( inComparisonValue : * = null ) : Object
		{
			super.evaluate( inComparisonValue );

			if( condition )
			{
				if( condition is IConditionalExpressionGroup )
					IConditionalExpressionGroup( condition ).withValue = _context.variables[ _name ];
				return condition.evaluate( _context.variables[ _name ] );
			}
			return false;
		}

		public function set name( inValue : String ) : void
		{
			if( inValue && inValue.length > 0 )
			{
				if( !inValue.match( /^\$\w+$/ ) )
					inValue = "$" + inValue;
			}
			_name = inValue;
		}
	}
}
