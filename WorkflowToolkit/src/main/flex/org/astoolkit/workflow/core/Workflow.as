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
package org.astoolkit.workflow.core
{

	import flash.events.EventDispatcher;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IMXMLObject;
	import mx.logging.ILogger;
	
	import org.astoolkit.commons.collection.annotation.IteratorSource;
	import org.astoolkit.commons.io.transform.api.*;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.commons.reflection.AnnotationUtil;
	import org.astoolkit.commons.reflection.AutoConfig;
	import org.astoolkit.commons.reflection.Type;
	import org.astoolkit.workflow.annotation.*;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.constant.TaskStatus;
	import org.astoolkit.workflow.internals.*;

	[Event(
		name="started",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="warning",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="fault",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="completed",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="progress",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="prepare",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="subtaskInitialized",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="subtaskPrepared",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="subtaskStarted",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="subtaskFault",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="subtaskCompleted",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="subtaskProgress",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name="subtaskAborted",
		type="org.astoolkit.workflow.core.WorkflowEvent" )]
	[Bindable]
	[DefaultProperty( "rootTask" )]
	public class Workflow extends EventDispatcher implements IWorkflow
	{

		//----------------------------------- STATIC ----------------------------------------------
		/**
		 * @private
		 */
		private static const LOGGER : ILogger = getLogger( Workflow );

		/**
		 * @private Static initialization of toolkit.
		 */
		private static const _annotationsInit : Boolean = (function() : Boolean
		{
			AnnotationUtil.registerAnnotation( new ClassFactory( Featured ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( Template ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( TaskInput ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( AutoConfig ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( IteratorSource ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( TaskDescriptor ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( InjectPipeline ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( OverrideChildrenProperty ) );
			Type.clearCache();
			return true;
		})();

		private var _retainedWorkflows : Object = {};

		//----------------------------------- END OF STATIC ---------------------------------------

		protected var _childNodes : Array;

		protected var _context : IWorkflowContext;

		protected var _contextFactory : IFactory;

		protected var _delegate : IWorkflowDelegate;

		protected var _inputFilter : Object;

		protected var _rootTask : IWorkflowTask;

		protected var _running : Boolean;

		public function get ENV() : ContextVariablesProvider
		{
			return _context ? _context.variables : null;
		}

		public function set ENV( inValue : * ) : void
		{
		/*
			empty setter definition necessary to avoid the read-only
			bindable property warning
		*/
		}

		public function get context() : IWorkflowContext
		{
			return _context;
		}

		public function set contextFactory( inValue : IFactory ) : void
		{
			_contextFactory = inValue;
		}

		public function get rootTask() : IWorkflowTask
		{
			return _rootTask;
		}

		public function set rootTask( inValue : IWorkflowTask ) : void
		{
			_rootTask = inValue;
		}

		public function childNodeAdded( inNode : Object ) : void
		{
			if( !_childNodes )
				_childNodes = [];
			_childNodes.push( inNode );
		}

		public function run( inTaskInput : * = undefined ) : *
		{
			if( !_rootTask )
				throw new Error( "No task declared for this workflow" );

			if( _context && _context.status != TaskStatus.STOPPED )
				throw new Error( "Attempt to run an already running workflow" );

			_delegate = new PrivateWorkflowDelegate( this );
			var w : ITaskLiveCycleWatcher;

			if( !_contextFactory )
				_contextFactory = new ClassFactory( DefaultWorkflowContext );

			if( !_context )
			{
				_context = _contextFactory.newInstance() as IWorkflowContext;
			}
			_context.init( this );

			try
			{
				initialize();
			}
			catch( e : Error )
			{
				throw new Error( "Workflow initialization failed.\nCause:\n" +
					e.message + "\n" +
					e.getStackTrace() );
				return;
			}
			prepare();

			if( _inputFilter )
				IIODataTransformerClient( _rootTask ).inputFilter = _inputFilter;
			_rootTask.input = inTaskInput;

			for each( w in _context.taskLiveCycleWatchers )
				w.afterTaskDataSet( _rootTask );

			for each( w in _context.taskLiveCycleWatchers )
				w.beforeTaskBegin( _rootTask );
			_rootTask.delegate = _delegate;
			var out : * = _rootTask.begin();

			if( !_rootTask.running )
			{
				return out;
			}
			else
			{
				for each( w in _context.taskLiveCycleWatchers )
					w.afterTaskBegin( _rootTask );
				_retainedWorkflows[ this ] = this;
			}
		}

		protected function cleanup() : void
		{
			delete _retainedWorkflows[ this ];
			_rootTask.cleanUp();
			_context.status = TaskStatus.STOPPED;
			_context = null;
		}

		protected function initialize() : void
		{
			_rootTask.context = _context;
			_rootTask.initialize();

			if( _childNodes )
			{
				_context.configureObjects( _childNodes );
			}
		}

		protected function prepare() : void
		{
			_rootTask.prepare();
		}

		//--------------------------------- ROOT TASK DELEGATE ------------------------------------

		astoolkit_private function onRootTaskAbort() : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskAbort( _rootTask );
			cleanup();
		}

		astoolkit_private function onRootTaskBegin() : void
		{
		}

		astoolkit_private function onRootTaskComplete() : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskComplete( _rootTask );
			dispatchEvent( new WorkflowEvent( WorkflowEvent.COMPLETED, _context, null, _rootTask.output ) );
			cleanup();
		}

		astoolkit_private function onRootTaskFault() : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskFail( _rootTask );
			cleanup();
		}

		astoolkit_private function onRootTaskInitialize() : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskInitialize( _rootTask );
		}

		astoolkit_private function onRootTaskPrepare() : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskPrepared( _rootTask );
		}

		astoolkit_private function onRootTaskProgress() : void
		{
		}

		astoolkit_private function onRootTaskResume() : void
		{
		}

		astoolkit_private function onRootTaskSuspend() : void
		{
		}
		//------------------------------ END OF ROOT TASK DELEGATE --------------------------------
		
		public function set dataTransformerRegistry(inRegistry:IIODataTransformerRegistry):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function set inputFilter(inValue:Object):void
		{
			_inputFilter = inValue;
		}
		
	}
}

import org.astoolkit.commons.ns.astoolkit_private;
import org.astoolkit.workflow.api.IWorkflowDelegate;
import org.astoolkit.workflow.api.IWorkflowTask;
import org.astoolkit.workflow.core.Workflow;

use namespace astoolkit_private;

class PrivateWorkflowDelegate implements IWorkflowDelegate
{

	private var _workflow : Workflow;

	public function PrivateWorkflowDelegate( inWorkflow : Workflow )
	{
		_workflow = inWorkflow;
	}

	public function onAbort( inTask : IWorkflowTask, inMessage : String ) : void
	{
		_workflow.onRootTaskAbort();
	}

	public function onBegin( inTask : IWorkflowTask ) : void
	{
		_workflow.onRootTaskBegin();
	}

	public function onComplete( inTask : IWorkflowTask ) : void
	{
		_workflow.onRootTaskComplete();
	}

	public function onFault(inTask:IWorkflowTask, inMessage:String) : void
	{
		_workflow.onRootTaskFault();
	}

	public function onInitialize(inTask:IWorkflowTask) : void
	{
		_workflow.onRootTaskInitialize();
	}

	public function onPrepare(inTask:IWorkflowTask) : void
	{
		_workflow.onRootTaskPrepare();
	}

	public function onProgress(inTask:IWorkflowTask) : void
	{
		_workflow.onRootTaskProgress();
	}

	public function onResume(inTask:IWorkflowTask) : void
	{
		_workflow.onRootTaskResume();
	}

	public function onSuspend(inTask:IWorkflowTask) : void
	{
		_workflow.onRootTaskSuspend();
	}
}
