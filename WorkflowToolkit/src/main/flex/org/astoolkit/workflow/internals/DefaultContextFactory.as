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
package org.astoolkit.workflow.internals
{

	import flash.events.Event;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import org.astoolkit.commons.process.api.IDeferrableProcess;
	import org.astoolkit.commons.reflection.SelfWireUtil;
	import org.astoolkit.commons.reflection.PropertyDataBuilderInfo;
	import org.astoolkit.commons.configuration.api.ISelfWiring;
	import org.astoolkit.workflow.api.IContextConfig;
	import org.astoolkit.workflow.api.IWorkflowContext;
	import org.astoolkit.workflow.config.api.IObjectPropertyDefaultValue;

	public class DefaultContextFactory implements IFactory, ISelfWiring
	{
		private var _classFactoryMappings : Array;

		private var _factory : ClassFactory;

		/**
		 * @private
		 */
		protected var _selfWiringChildren : Array;

		protected var _propertiesDataProviderInfo:Vector.<PropertyDataBuilderInfo>;

		public function set selfWiringChildren( inValue : Array ) : void
		{
			_selfWiringChildren = inValue;
		}

		[ArrayItemType("org.astoolkit.commons.factory.ClassFactoryMapping")]
		public function set classFactoryMappings( inValue : Array ) : void
		{
			_classFactoryMappings = inValue;
		}

		[AutoAssign]
		public var config : IContextConfig;

		[AutoAssign]
		public var defaults : Vector.<IObjectPropertyDefaultValue>;

		[AutoAssign]
		public var dropIns : Vector.<Object>;

		public function initialized( document : Object, id : String ) : void
		{
		}

		public function newInstance() : *
		{
			if( !_factory )
			{
				_factory = new ClassFactory( DefaultWorkflowContext );

				if( _selfWiringChildren && _selfWiringChildren.length > 0 )
					_propertiesDataProviderInfo = 
						SelfWireUtil.autoAssign( this, _selfWiringChildren );
			}

			if( _propertiesDataProviderInfo )
			{
				var value : *;

				for each( var prop : PropertyDataBuilderInfo in _propertiesDataProviderInfo )
				{
					value = prop.dataProvider.getData();

					if( value  === undefined )
					{
						if( prop.dataProvider is IDeferrableProcess && IDeferrableProcess( prop.dataProvider ).isProcessDeferred() )
						{
							throw new Error( "Context data providers cannot be asynchronous" );
						}
					}
					else
					{
						this[ prop.name ] = value;
					}

				}
			}
			_factory.properties = {
					config: config,
					dropIns: dropIns
				};
			var context : IWorkflowContext = _factory.newInstance() as IWorkflowContext;
			context.addEventListener( 
				"initialized", 
				function( inEvent : Event ) : void
				{
					context.removeEventListener( "initialized", arguments.callee );
					context.config.defaults = defaults;
					context.config.classFactoryMappings = _classFactoryMappings;					
				},false, int.MAX_VALUE );

			return context;
		}
	}
}
