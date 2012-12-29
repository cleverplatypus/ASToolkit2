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

	[DefaultProperty( "children" )]
	public class All extends BaseConditionalExpressionGroup
	{

		override public function evaluate( inComparisonValue : * = undefined ) : Object
		{
			var compared : * = resolveSource( inComparisonValue );

			if( !children )
				return true  && !_negate;

			for each( var child : IConditionalExpression in children )
			{
				var result : Object;

				if( child.async )
					result = child.lastResult !== undefined ?
						child.lastResult :
						child.evaluate( compared );
				else
					result = child.evaluate( compared );

				if( result is Boolean && result == false )
					return false  && !_negate;

				if( result is AsyncExpressionToken )
				{
					if( child.lastResult !== undefined )
						return child.lastResult;
					else
						return result;
				}
			}
			return true  && !_negate;
		}
	}
}
