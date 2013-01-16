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
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	import mx.core.IFactory;
	import mx.core.IMXMLObject;
	import mx.logging.ILogger;
	import mx.utils.UIDUtil;
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.conditional.api.IExpressionResolver;
	import org.astoolkit.commons.eval.api.IRuntimeExpressionEvaluator;
	import org.astoolkit.commons.factory.*;
	import org.astoolkit.commons.factory.api.*;
	import org.astoolkit.commons.io.transform.api.*;
	import org.astoolkit.commons.reflection.Field;
	import org.astoolkit.commons.reflection.ManagedObject;
	import org.astoolkit.commons.reflection.Type;
	import org.astoolkit.commons.utils.ListUtil;
	import org.astoolkit.commons.utils.ObjectCompare;
	import org.astoolkit.workflow.annotation.Featured;
	import org.astoolkit.workflow.annotation.Template;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.conditional.WorkflowDataSourceResolverDelegate;
	import org.astoolkit.workflow.constant.TaskStatus;
	import org.astoolkit.workflow.core.Do;

	[Bindable]
	[Event( name="initialized", type="flash.events.Event" )]
	/**
	 * @inherit
	 */
	public class DefaultWorkflowContext extends EventDispatcher implements IWorkflowContext
	{
		/*
		* TODO: at the moment the extensions resolving code is executed
		* 		at every context instanciation. This is not necessary
		*		as such configuration is common to every instance of
		*		a given factory. IContextConfig were originally meant
		*		to keep non-changing configuration.
		*		Also, consider making this class smaller.
		*/
		private static const LOGGER : ILogger = getLogger( DefaultWorkflowContext );

		private var _config : IContextConfig;

		private var _configuredObjects : Object = {};

		private var _data : Object;

		private var _dataSourceResolverDelegate : IIODataSourceResolverDelegate;

		private var _dropIns : Object;

		private var _factoryResolver : IFactoryResolver;

		private var _failedTask : IWorkflowTask;

		private var _initialized : Boolean;

		private var _objectsConfigurers:Array;

		private var _owner : IWorkflow;

		private var _plugIns : Vector.<IContextPlugIn>

		private var _pooledFactories : Object;

		private var _runninTask : IWorkflowTask;

		private var _runningStack : Vector.<IWorkflowTask>;

		private var _status : String;

		private var _suspendableFunctions : SuspendableFunctionRegistry;

		private var _taskLiveCycleWatchers : Vector.<ITaskLiveCycleWatcher>;

		private var _variables : ContextVariablesProvider;

		public function get config() : IContextConfig
		{
			return _config;
		}

		public function set config( inValue : IContextConfig ) : void
		{
			if( !_config )
				_config = inValue;
		}

		public function get data() : Object
		{
			return _data;
		}

		public function get dataSourceResolverDelegate() : IIODataSourceResolverDelegate
		{
			return _dataSourceResolverDelegate;
		}

		public function set dropIns( inValue : Object ) : void
		{
			_dropIns = inValue;
		}

		public function get failedTask() : IWorkflowTask
		{
			return _failedTask;
		}

		public function set failedTask( inFailedTask : IWorkflowTask ) : void
		{
			_failedTask = inFailedTask;
		}

		public function get initialized() : Boolean
		{
			return _initialized;
		}

		public function get owner() : IWorkflow
		{
			return _owner;
		}

		public function get plugIns() : Vector.<IContextPlugIn>
		{
			return _plugIns;
		}

		public function get runningStack() : Vector.<IWorkflowTask>
		{
			return _runningStack.concat();
		}

		public function get runningTask() : IWorkflowTask
		{
			return _runninTask;
		}

		public function set runningTask( inTask : IWorkflowTask ) : void
		{
			_runninTask = inTask;
		}

		public function get status() : String
		{
			return _status;
		}

		public function set status( inStatus : String ) : void
		{
			_status = inStatus;

			if( _status == TaskStatus.STOPPED )
				_initialized = false;
		}

		public function get suspendableFunctions() : SuspendableFunctionRegistry
		{
			return _suspendableFunctions;
		}

		public function get taskLiveCycleWatchers() : Vector.<ITaskLiveCycleWatcher>
		{
			return _taskLiveCycleWatchers;
		}

		public function get variables() : ContextVariablesProvider
		{
			return _variables;
		}

		public function set variables( inValue : ContextVariablesProvider ) : void
		{
			//dummy setter
		}

		public function addTaskLiveCycleWatcher( 
			inValue : ITaskLiveCycleWatcher, 
			inGroupScope : ITasksGroup = null ) : void
		{
			_taskLiveCycleWatchers.push( inValue );
			_taskLiveCycleWatchers.sort(
				function( inA : ITaskLiveCycleWatcher, inB : ITaskLiveCycleWatcher ) : int
				{
					return ObjectCompare.compare( inB.taskWatcherPriority, inA.taskWatcherPriority )
				} )
		}

		public function cleanup() : void
		{
			_data = null;
			_pooledFactories = null;

			if( _config.dataTransformerRegistry is IPooledFactory )
				IPooledFactory( _config.dataTransformerRegistry ).cleanup();

			if( _config.iteratorFactory is IPooledFactory )
				IPooledFactory( _config.iteratorFactory ).cleanup();
		}

		public function configureObjects( inObjects : Array, inDocument : Object ) : void
		{
			if( inObjects && inObjects.length > 0 )
			{
				for each( var object : Object in inObjects )
					configureObject( object, inDocument );

				if( _config.objectConfigurers )
				{
					for each( var configurer : IObjectConfigurer in _config.objectConfigurers )
						configurer.configureObjects( inObjects, inDocument );
				}

			}
		}

		public function fail(inSource:Object, inMessage:String) : void
		{
			LOGGER.fatal( "An unexpected error happened:\n{0}", inMessage );
			owner.rootTask.abort();
		}

		public function getPooledFactory( 
			inClass : Class, 
			inDelegate : IPooledFactoryDelegate = null ) : IPooledFactory
		{
			var factory : PooledFactory = _pooledFactories[ inClass ];

			if( !factory )
				factory = PooledFactory.create( inClass, inDelegate );
			return factory;
		}

		public function init( inOwner : IWorkflow ) : void
		{
			_owner = inOwner;
			LOGGER.info( "Initializing context" );
			_variables = new ContextVariablesProvider( this );
			_dataSourceResolverDelegate = new WorkflowDataSourceResolverDelegate( this );
			_pooledFactories = {};
			_data = {};
			_taskLiveCycleWatchers = new Vector.<ITaskLiveCycleWatcher>();
			_taskLiveCycleWatchers.push( _variables );

			if( !_config )
				_config = new DefaultContextConfig();
			LOGGER.info( "Initializing context configuration" );
			_config.init();
			_factoryResolver = _config;
			_plugIns = new Vector.<IContextPlugIn>();

			for each( var dropIn : Object in _dropIns )
			{
				inspectExtension( dropIn );
			}
			_runningStack = new Vector.<IWorkflowTask>();
			_status = TaskStatus.STOPPED;
			_suspendableFunctions = new SuspendableFunctionRegistry();
			_suspendableFunctions.initResumeCallBacks();
			_initialized = true;
			dispatchEvent( new Event( "initialized" ) );
			LOGGER.info( "Context initialized" );
		}

		public function removeTaskLiveCycleWatcher( inValue : ITaskLiveCycleWatcher ) : void
		{
			if( _taskLiveCycleWatchers.indexOf( inValue ) > -1 )
				_taskLiveCycleWatchers.splice( _taskLiveCycleWatchers.indexOf( inValue ), 1 );
		}

		public function resolveIterator( inSource : Object, inIteratorConfig : Object = null ) : IIterator
		{
			var out : IIterator =
				config.iteratorFactory.iteratorForSource( inSource );

			if( out && out.supportsSource( inSource ) )
			{
				out.source = inSource;

				if( inIteratorConfig )
				{
					for( var key : String in inIteratorConfig )
					{
						if( Object( out ).hasOwnProperty( key ) )
							out[ key ] = inIteratorConfig[ key ];
					}
				}
				return out;
			}
			return null;

		}

		private function configureObject( inObject : Object, inDocument : Object ) : void
		{
			if( !_configuredObjects.hasOwnProperty( UIDUtil.getUID( inObject ) ) )
			{
				LOGGER.debug( 
					"Workflow context configuring object: {0}",
					getQualifiedClassName( inObject ) );

				if( isCollection( inObject ) )
				{
					configureObjects( ListUtil.convert( inObject, Array ) as Array, inDocument );
					return;
				}

				if( inObject is IMXMLObject )
					IMXMLObject( inObject ).initialized( inDocument, null );

				if( inObject is IContextAwareElement )
					inObject.context = this;

				if( inObject is IExpressionResolver )
				{
					var delegate : ContextAwareExpressionResolver = new ContextAwareExpressionResolver();
					delegate.context = this;
					IExpressionResolver( inObject ).delegate = delegate;
				}

				if( inObject is IIODataTransformerClient )
					IIODataTransformerClient( inObject ).dataTransformerRegistry = 
						config.dataTransformerRegistry;

				if( inObject is IIODataSourceClient )
					IIODataSourceClient( inObject ).sourceResolverDelegate = 
						dataSourceResolverDelegate;

				if( inObject is IFactoryResolverClient )
					IFactoryResolverClient( inObject ).factoryResolver = _factoryResolver;
				_configuredObjects[  UIDUtil.getUID( inObject ) ] = true;
			}

			var ci : Type = Type.forType( inObject );

			for each( var fi : Field in ci.getFieldsWithAnnotation( Featured ) )
			{
				LOGGER.debug( 
					"{0} has featured property: {1}",
					getQualifiedClassName( inObject ),
					fi.name );

				if( !fi.writeOnly && inObject[ fi.name ] != null )
					configureObject( inObject[ fi.name ], inDocument );
			}

		}

		private function inspectExtension( inObject : Object ) : void
		{
			var disabledExtensionsLUT : Object = {};

			if( inObject is IContextPlugIn && 
				IContextPlugIn( inObject ).extensions )
			{
				for each( var ext : Class in IContextPlugIn( inObject ).disabledExtensions )
				{
					disabledExtensionsLUT[ ext ] = ext;
				}
			}

			if( inObject is IObjectConfigurer &&
				!disabledExtensionsLUT.hasOwnProperty( getClass( inObject ) ) )
			{
				if( !_config.objectConfigurers )
					_config.objectConfigurers = new Vector.<IObjectConfigurer>();
				_config.objectConfigurers.push( inObject );
			}

			if( inObject is IContextPlugIn )
			{
				_plugIns.push( inObject );
				LOGGER.info( "Adding context plug-in: " +
					getQualifiedClassName( inObject ) );
				IContextPlugIn( inObject ).init();

				for each( var e : Object in IContextPlugIn( inObject ).extensions )
				{
					inspectExtension( e );
				}
			}
			var classInfo : Type = Type.forType( inObject );
			var templateInterfaces : Vector.<Type> =
				classInfo.getInterfacesWithAnnotationsOfType( Template );

			if( templateInterfaces.length > 0
				&& !( classInfo.implementsInterface( ITaskTemplate ) ) )
			{
				config.templateRegistry.registerImplementation( inObject );
				LOGGER.info( "Registering template implementation for interface: " +
					getQualifiedClassName( Type( templateInterfaces[ 0 ] ).type ) );
			}

			if( inObject is ITaskLiveCycleWatcher )
			{
				_taskLiveCycleWatchers.push( inObject );
				LOGGER.info( "Adding task livecycle watcher: " +
					getQualifiedClassName( inObject ) );
			}

			if( inObject is IIODataTransformer )
			{
				_config
					.dataTransformerRegistry
					.registerTransformer( inObject as IIODataTransformer );
				LOGGER.info( "Registering IIODataTransformer : " +
					getQualifiedClassName( inObject ) );
			}

			if( inObject is IRuntimeExpressionEvaluator )
			{
				_config.runtimeExpressionEvalutators.registerEvaluator( inObject );
				LOGGER.info( "Registering IRuntimeExpressionEvaluator : " +
					getQualifiedClassName( inObject ) );
			}
		}
	}
}
