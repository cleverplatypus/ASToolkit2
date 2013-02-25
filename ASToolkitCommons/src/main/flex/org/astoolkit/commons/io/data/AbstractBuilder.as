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

	import mx.core.IMXMLObject;
	import mx.logging.ILogger;

	import org.astoolkit.commons.conditional.api.IExpressionResolver;
	import org.astoolkit.commons.factory.api.IFactoryResolver;
	import org.astoolkit.commons.factory.api.IFactoryResolverClient;
	import org.astoolkit.commons.io.data.api.IDataBuilder;
	import org.astoolkit.commons.process.api.IDeferrableProcess;
	import org.astoolkit.commons.reflection.AutoAssignUtil;
	import org.astoolkit.commons.reflection.PropertyDataBuilderInfo;
	import org.astoolkit.commons.utils.getLogger;
	import org.astoolkit.commons.configuration.api.ISelfWiring;
	import org.astoolkit.commons.wfml.api.IChildrenAwareDocument;
	import org.astoolkit.commons.wfml.api.IComponent;

	[DefaultProperty( "selfWiringChildren" )]
	public class AbstractBuilder implements IDataBuilder, ISelfWiring, IFactoryResolverClient, IComponent, IDeferrableProcess
	{
		private static const LOGGER : ILogger = getLogger( AbstractBuilder );

		protected var _selfWiringChildren : Array;

		protected var _deferredExecutionWatchers : Vector.<Function>;

		protected var _document : Object;

		protected var _expressionResolvers : Vector.<IExpressionResolver>;

		protected var _factoryResolver : IFactoryResolver;

		protected var _id : String;

		protected var _pid : String;

		protected var _propertiesDataProviderInfo : Vector.<PropertyDataBuilderInfo>;

		protected var _providedType : Class;

		public function set selfWiringChildren( inValue : Array ) : void
		{
			_selfWiringChildren = inValue;
		}

		[AutoAssign]
		public function set expressionResolvers( value : Vector.<IExpressionResolver> ) : void
		{
			_expressionResolvers = value;
		}

		public function set factoryResolver( inValue : IFactoryResolver ) : void
		{
			_factoryResolver = inValue;
		}

		public function get pid() : String
		{
			return _pid;
		}

		public function set pid( inValue : String ) : void
		{
			_pid = inValue;
		}

		public function get builtDataType() : Class
		{
			return _providedType;
		}

		public function addDeferredProcessWatcher( inWatcher : Function ) : void
		{
			if( !_deferredExecutionWatchers )
				_deferredExecutionWatchers = new Vector.<Function>();
			_deferredExecutionWatchers.push( inWatcher );
		}

		public function getData() : *
		{
			throw new Error( "AbstractBuilder is abstract" );
		}

		public final function initialized( inDocument : Object, inId : String ) : void
		{
			if( _document )
				return;
			_document = inDocument;
			_id = inId;
			initAutoConfigContainer();

			if( _document is IChildrenAwareDocument )
				IChildrenAwareDocument( _document ).childNodeAdded( this );
			postInitialized();
		}

		public function isProcessDeferred() : Boolean
		{
			return _deferredExecutionWatchers != null &&
				_deferredExecutionWatchers.length > 0;
		}

		protected function initAutoConfigContainer() : void
		{
			_propertiesDataProviderInfo = AutoAssignUtil.autoAssign( this, _selfWiringChildren );
		}

		protected function notifyDeferredProcessWatchers() : void
		{
			var watchers : Vector.<Function> = _deferredExecutionWatchers.concat();
			_deferredExecutionWatchers.length = 0;

			while( watchers.length > 0 )
				( watchers.pop() as Function )( this );
		}

		protected function postInitialized() : void
		{
			LOGGER.debug( "empty postInitialized() called" );
		}
	}
}
