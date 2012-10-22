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
	import org.astoolkit.commons.io.transform.api.IIODataTransformer;

	[DefaultProperty( "condition" )]
	public class WithCurrentData extends BaseConditionalWorkflowExpression
	{
		public var condition : IConditionalExpression;

		public var inputFilter : Object;

		override public function evaluate( inComparisonValue : * = null ) : Object
		{
			super.evaluate( inComparisonValue );

			if( condition )
			{
				var data : Object;

				if( inputFilter )
				{
					var transformer : IIODataTransformer =
						_context
						.config
						.dataTransformerRegistry
						.getTransformer(
						_context.variables.$currentData,
						inputFilter );

					if( transformer )
					{
						data = transformer.transform(
							_context.variables.$currentData,
							inputFilter );
					}
				}
				else
					data = _context.variables.$currentData;

				if( condition is IConditionalExpressionGroup )
					IConditionalExpressionGroup( condition ).withValue = data
				return condition.evaluate( data );
			}
			return false;
		}
	}
}
