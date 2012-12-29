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
package org.astoolkit.workflow.task.misc
{

	import mx.collections.ICollectionView;
	import mx.collections.IList;
	import org.astoolkit.commons.conditional.api.IConditionalExpression;
	import org.astoolkit.commons.conditional.api.IConditionalExpressionGroup;
	import org.astoolkit.commons.utils.ListUtil;
	import org.astoolkit.workflow.core.BaseTask;

	[TaskInput( "Vector,Array,mx.collections.ICollectionView" )]
	[DefaultProperty( "includeCondition" )]
	public class FilterList extends BaseTask
	{
		public var includeCondition : IConditionalExpression;

		[Bindable]
		[InjectPipeline]
		/**
		 * a <code>Array, Vector.&lt;&#42;&gt;, IList</code> object
		 */
		public var source : Object;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			try
			{
				if( source is Array || source is Vector )
				{
					complete( source.filter( filterFunction ) );
				}
				else
				{
					ICollectionView( source ).filterFunction = filterFunction;
					ICollectionView( source ).refresh();
				}
			}
			catch( e : Error )
			{
				fail( e.message );
			}
		}

		private function filterFunction( inValue : Object, ... rest ) : Boolean
		{
			return includeCondition.evaluate( inValue ) == true;

		}
	}
}
