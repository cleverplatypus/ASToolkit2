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
/**
 * Transforms the filtered input using <code>transformer</code> if the former
 * is of type <code>type</code>
 */
package org.astoolkit.workflow.task.pipeline
{

	import flash.utils.getQualifiedClassName;

	import mx.core.IFactory;
	import mx.logging.ILogger;
	import mx.logging.Log;

	import org.astoolkit.commons.io.transform.api.IIODataTransformer;
	import org.astoolkit.commons.mapping.MappingConfig;
	import org.astoolkit.lang.util.getLogger;
	import org.astoolkit.workflow.core.BaseTask;

	[DefaultProperty( "transformer" )]
	public class TransformOnInputType extends BaseTask
	{
		/**
		 * @private
		 */
		private static const LOGGER : ILogger = getLogger( TransformOnInputType );

		/**
		 * the transformer to be applied to the (already filtered) task input
		 */
		[Featured]
		public var transformer : Object;

		/**
		 * the type to compare the (filtered) input data's class to
		 */
		public var type : Class;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !transformer )
			{
				LOGGER.warn( "No trasformer declared. Completing." );
				complete();
				return;
			}

			if( !type )
			{
				fail( "No type declared for comparison" );
				return;
			}

			if( filteredInput is type )
			{
				var usedTransformer : IIODataTransformer =
					transformer is IIODataTransformer ?
					transformer as IIODataTransformer :
					_dataTransformerRegistry.getTransformer( filteredInput, transformer );

				if( usedTransformer )
				{
					complete( usedTransformer.transform( filteredInput, transformer ) );
					return;
				}
			}
			fail( "Unable to transform" );
		}
	}
}
