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
	import org.astoolkit.commons.io.data.api.IDataProvider;
	import org.astoolkit.commons.process.api.IDeferrableProcess;
	import org.astoolkit.commons.reflection.AutoConfigUtil;
	import org.astoolkit.commons.reflection.PropertyDataProviderInfo;
	import org.astoolkit.commons.utils.IChildrenAwareDocument;
	import org.astoolkit.commons.wfml.IAutoConfigContainerObject;
	import org.astoolkit.commons.wfml.IComponent;

	[DefaultProperty("autoConfigChildren")]
	public class AbstractBuilder implements IDataProvider, IAutoConfigContainerObject, IFactoryResolverClient, IComponent, IDeferrableProcess
	{
		private static const LOGGER : ILogger = getLogger( AbstractBuilder );

		protected var _autoConfigChildren : Array;

		protected var _deferredExecutionWatchers : Vector.<Function>;

		protected var _document : Object;

		protected var _expressionResolvers : Vector.<IExpressionResolver>;

		protected var _factoryResolver : IFactoryResolver;

		protected var _id : String;

		protected var _pid : String;

		protected var _propertiesDataProviderInfo:Vector.<PropertyDataProviderInfo>;

		protected var _providedType : Class;

		public function set autoConfigChildren( inValue : Array ) : void
		{
			_autoConfigChildren  = inValue;
		}

		[AutoConfig]
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

		public function get providedType() : Class
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

		public final function initialized( inDocument : Object, inId : String) : void
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
			_propertiesDataProviderInfo = AutoConfigUtil.autoConfig( this, _autoConfigChildren );
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
