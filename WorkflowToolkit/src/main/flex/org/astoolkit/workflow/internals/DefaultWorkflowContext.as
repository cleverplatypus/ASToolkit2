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

	import mx.core.IMXMLObject;
	import mx.logging.ILogger;
	import mx.utils.UIDUtil;

	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.conditional.api.IExpressionResolver;
	import org.astoolkit.commons.configuration.api.IObjectConfigurer;
	import org.astoolkit.commons.eval.api.IRuntimeExpressionEvaluator;
	import org.astoolkit.commons.factory.*;
	import org.astoolkit.commons.factory.api.*;
	import org.astoolkit.commons.io.transform.api.*;
	import org.astoolkit.commons.reflection.Field;
	import org.astoolkit.commons.reflection.Type;
	import org.astoolkit.commons.utils.ListUtil;
	import org.astoolkit.commons.utils.ObjectCompare;
	import org.astoolkit.commons.utils.getClass;
	import org.astoolkit.commons.utils.getLogger;
	import org.astoolkit.workflow.annotation.Featured;
	import org.astoolkit.workflow.annotation.Template;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.conditional.WorkflowDataSourceResolverDelegate;
	import org.astoolkit.workflow.constant.TaskStatus;

	[Event( name = "initialized", type = "flash.events.Event" )]
	/**
	 * @inherit
	 */
	public class DefaultWorkflowContext extends EventDispatcher implements IWorkflowContext
	{
		/*
		* TODO: at the moment the config creation code is executed
		* 		at every context instanciation. This is not necessary
		*		as such configuration is common to every context instance returned by
		*		a given factory. IContextConfig were originally meant
		*		to keep non-changing configuration.
		*		Context factory should create the config object once.
		*		If config contains stateful objects, the latter might be moved
		*		to the context class, or config objects could be pooled in the
		*		context factory
		*/
		private static const LOGGER : ILogger = getLogger( DefaultWorkflowContext );

		private var _config : IContextConfig;

		private var _dataSourceResolverDelegate : IIODataSourceResolverDelegate;

		private var _dropIns : Vector.<Object>;

		private var _factoryResolver : IFactoryResolver;

		private var _failedTask : IWorkflowTask;

		private var _initialized : Boolean;

		private var _objectsConfigurer : ContextObjectConfigurer;

		private var _owner : IWorkflow;

		private var _plugIns : Vector.<IContextPlugIn>

		private var _pooledFactories : Object;

		private var _runninTask : IWorkflowTask;

		private var _runningStack : Vector.<IWorkflowTask>;

		private var _status : String;

		private var _suspendableFunctions : SuspendableFunctionRegistry;

		private var _taskLiveCycleWatchers : Vector.<ITaskLiveCycleWatcher>;

		private var _variables : ContextVariablesProvider;

		private var _plugInData : Object;

		public function get config() : IContextConfig
		{
			return _config;
		}

		public function set config( inValue : IContextConfig ) : void
		{
			if( !_config )
				_config = inValue;
		}

		public function get dataSourceResolverDelegate() : IIODataSourceResolverDelegate
		{
			return _dataSourceResolverDelegate;
		}

		public function set dropIns( inValue : Vector.<Object> ) : void
		{
			_dropIns = inValue;
		}

		//TODO: is this still necessary?
		public function get failedTask() : IWorkflowTask
		{
			return _failedTask;
		}

		public function set failedTask( inFailedTask : IWorkflowTask ) : void
		{
			_failedTask = inFailedTask;
		}

		public function get isInitialized() : Boolean
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

		//TODO: is this still necessary?
		public function get runningStack() : Vector.<IWorkflowTask>
		{
			return _runningStack.concat();
		}

		public function get runningTask() : IWorkflowTask
		{
			return _runninTask;
		}

		//TODO: is this still necessary?
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

		//TODO: data binding to be abandoned. setter not necessary anymore
		[Bindable]
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
			_pooledFactories = null;

			if( _config.dataTransformerRegistry is IPooledFactory )
				IPooledFactory( _config.dataTransformerRegistry ).cleanup();

			if( _config.iteratorFactory is IPooledFactory )
				IPooledFactory( _config.iteratorFactory ).cleanup();
		}

		public function configureObjects( inObjects : Array, inDocument : Object ) : void
		{
			_objectsConfigurer.configureObjects( inObjects, inDocument );

			if( _config.objectConfigurers )
				for each( var configurer : IObjectConfigurer in _config.objectConfigurers )
					configurer.configureObjects( inObjects, inDocument );
		}

		public function fail( inSource : Object, inMessage : String ) : void
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

		public function init( inOwner : IWorkflow, inAdditionalDropIns : Vector.<Object> = null ) : void
		{
			_owner = inOwner;
			LOGGER.info( "Initializing context" );
			_objectsConfigurer = new ContextObjectConfigurer( this );
			_variables = new ContextVariablesProvider( this );
			_dataSourceResolverDelegate = new WorkflowDataSourceResolverDelegate( this );
			_pooledFactories = {};
			_plugInData = {};
			_taskLiveCycleWatchers = new Vector.<ITaskLiveCycleWatcher>();
			_taskLiveCycleWatchers.push( _variables );

			if( !_config )
				_config = new DefaultContextConfig();
			LOGGER.info( "Initializing context configuration" );
			_config.init();
			_factoryResolver = _config;
			_plugIns = new Vector.<IContextPlugIn>();

			var allDropIns : Vector.<Object> = _dropIns;

			if( inAdditionalDropIns )
				allDropIns = allDropIns.concat( inAdditionalDropIns );

			for each( var dropIn : Object in allDropIns )
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

		//TODO: move this to the config API
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

		private function inspectExtension( inObject : Object ) : void
		{

			if( inObject is IContextAwareElement )
				IContextAwareElement( inObject ).context = this;

			if( inObject is IObjectConfigurer )
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
				_plugInData[ getClass( inObject ) ] = IContextPlugIn( inObject ).getInitialStateData( this );

				//TODO: config and stateful extensions must be loaded at different phases
				for each( var ce : Object in IContextPlugIn( inObject ).getConfigExtensions() )
				{
					inspectExtension( ce );
				}

				for each( var se : Object in IContextPlugIn( inObject ).getStatefulExtensions() )
				{
					inspectExtension( se );
				}
			}
			var classInfo : Type = Type.forType( inObject );

			if( classInfo ) //the inspected object might be an instance of an inner class, i.e. not public
			{

				var templateInterfaces : Vector.<Type> =
					classInfo.getInterfacesWithAnnotationsOfType( Template );

				if( templateInterfaces.length > 0
					&& !( classInfo.implementsInterface( ITaskTemplate ) ) )
				{
					config.templateRegistry.registerImplementation( inObject );
					LOGGER.info( "Registering template implementation for interface: " +
						getQualifiedClassName( Type( templateInterfaces[ 0 ] ).type ) );
				}
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

		public function getPluginData( inPlugIn : Class ) : Object
		{
			if( !inPlugIn )
				return null;

			if( _plugInData.hasOwnProperty( inPlugIn ) )
				return _plugInData[ inPlugIn ];
			return null;

		}
	}
}
