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
	
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import org.astoolkit.commons.factory.IPooledFactory;
	import org.astoolkit.commons.io.transform.api.IIODataTransformer;
	import org.astoolkit.commons.reflection.ClassInfo;
	import org.astoolkit.workflow.annotation.Template;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.constant.TaskStatus;
	
	[Bindable]
	public class DefaultWorkflowContext extends EventDispatcher implements IWorkflowContext
	{
		private static const LOGGER : ILogger =
			Log.getLogger( getQualifiedClassName( DefaultWorkflowContext ).replace( /:+/g, "." ));
		
		private var _config : IContextConfig;
		
		private var _data : Object;
		
		private var _dropIns : Object;
		
		private var _failedTask : IWorkflowTask;
		
		private var _initialized : Boolean;
		
		private var _plugIns : Vector.<IContextPlugIn>
		
		private var _runninTask : IWorkflowTask;
		
		private var _runningStack : Vector.<IWorkflowTask>;
		
		private var _status : String;
		
		private var _suspendableFunctions : SuspendableFunctionRegistry;
		
		private var _taskLiveCycleWatchers : Vector.<ITaskLiveCycleWatcher>;
		
		private var _variables : ContextVariablesProvider;
		
		public function addTaskLiveCycleWatcher( inValue : ITaskLiveCycleWatcher ) : void
		{
			_taskLiveCycleWatchers.push( inValue );
		}
		
		public function cleanup() : void
		{
			_data = null;
			
			if(_config.inputFilterRegistry is IPooledFactory)
				IPooledFactory( _config.inputFilterRegistry ).cleanup();
			
			if(_config.iteratorFactory is IPooledFactory)
				IPooledFactory( _config.iteratorFactory ).cleanup();
		}
		
		public function get config() : IContextConfig
		{
			return _config;
		}
		
		public function set config( inValue : IContextConfig ) : void
		{
			if(!_config)
				_config = inValue;
		}
		
		public function get data() : Object
		{
			return _data;
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
		
		public function init() : void
		{
			LOGGER.info( "Initializing context" );
			_variables = new ContextVariablesProvider( this );
			_data = {};
			_taskLiveCycleWatchers = new Vector.<ITaskLiveCycleWatcher>();
			_taskLiveCycleWatchers.push( _variables );
			
			if(!_config)
				_config = new DefaultContextConfig();
			LOGGER.info( "Initializing context configuration" );
			_config.init();
			_plugIns = new Vector.<IContextPlugIn>();
			
			for each(var dropIn : Object in _dropIns)
			{
				inspectExtension( dropIn );
			}
			_runningStack = new Vector.<IWorkflowTask>();
			_status = TaskStatus.STOPPED;
			_suspendableFunctions = new SuspendableFunctionRegistry();
			_suspendableFunctions.initResumeCallBacks();
			_initialized = true;
			LOGGER.info( "Context initialized" );
		}
		
		public function get initialized() : Boolean
		{
			return _initialized;
		}
		
		public function get plugIns() : Vector.<IContextPlugIn>
		{
			return _plugIns;
		}
		
		public function removeTaskLiveCycleWatcher( inValue : ITaskLiveCycleWatcher ) : void
		{
			if(_taskLiveCycleWatchers.indexOf( inValue ) > -1)
				_taskLiveCycleWatchers.splice( _taskLiveCycleWatchers.indexOf( inValue ), 1 );
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
			
			if(_status == TaskStatus.STOPPED)
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
		
		private function inspectExtension( inObject : Object ) : void
		{
			if(inObject is IContextPlugIn)
			{
				_plugIns.push( inObject );
				LOGGER.info( "Adding context plug-in: " +
					getQualifiedClassName( inObject ));
				IContextPlugIn( inObject ).init();
				
				for each(var e : Object in IContextPlugIn( inObject ).extensions)
				{
					inspectExtension( e );
				}
			}
			var classInfo : ClassInfo = ClassInfo.forType( inObject );
			var templateInterfaces : Vector.<ClassInfo> =
				classInfo.getInterfacesWithAnnotationsOfType( Template );
			
			if(templateInterfaces.length > 0
				&& !(classInfo.type is ITaskTemplate))
			{
				config.templateRegistry.registerImplementation( inObject );
				LOGGER.info( "Registering template implementation for interface: " +
					getQualifiedClassName( ClassInfo( templateInterfaces[0]).type ));
			}
			
			if(inObject is ITaskLiveCycleWatcher)
			{
				_taskLiveCycleWatchers.push( inObject );
				LOGGER.info( "Adding task livecycle watcher: " +
					getQualifiedClassName( inObject ));
			}
			
			if(inObject is IIODataTransformer)
			{
				_config.inputFilterRegistry.registerTransformer( inObject as IIODataTransformer );
				LOGGER.info( "Registering IIOFilter : " +
					getQualifiedClassName( inObject ));
			}
		}
	}
}
