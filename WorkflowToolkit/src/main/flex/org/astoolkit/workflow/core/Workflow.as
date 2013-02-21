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
	import mx.logging.ILogger;

	import org.astoolkit.commons.collection.annotation.IteratorSource;
	import org.astoolkit.commons.io.transform.api.*;
	import org.astoolkit.commons.reflection.*;
	import org.astoolkit.commons.utils.getLogger;
	import org.astoolkit.workflow.annotation.*;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.constant.*;
	import org.astoolkit.workflow.internals.*;

	[Event(
		name = "started",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "warning",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "fault",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "completed",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "progress",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "prepare",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
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
		private static const _ANNOTATIONS_INIT : Boolean = ( function() : Boolean
		{
			AnnotationUtil.registerAnnotation( new ClassFactory( Featured ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( Template ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( TaskInput ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( AutoAssign ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( IteratorSource ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( TaskDescriptor ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( InjectPipeline ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( ManagedObject ) );
			Type.clearCache();
			return true;
		} )();

		//----------------------------------- END OF STATIC ---------------------------------------

		private var _retainedWorkflows : Object = {};

		protected var _childNodes : Array;

		protected var _context : IWorkflowContext;

		protected var _contextFactory : IFactory;

		protected var _delegate : ITaskLiveCycleWatcher;

		protected var _inputFilter : Object;

		protected var _rootTask : IWorkflowTask;

		protected var _running : Boolean;

		protected var _contextDropIns : Vector.<Object>;

		public function get ENV() : ContextVariablesProvider
		{
			return _context ? _context.variables : null;
		}

		//TODO: as databinding won't be supported, the setter won't be needed anymore
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

		public function set dataTransformerRegistry( inRegistry : IIODataTransformerRegistry ) : void
		{
			// TODO Auto Generated method stub

		}

		public function set inputFilter( inValue : Object ) : void
		{
			_inputFilter = inValue;
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

			if( _context )
				_context.configureObjects( [ inNode ], this );
		}

		public function run( inTaskInput : * = undefined ) : *
		{
			if( !_rootTask )
				throw new Error( "No task declared for this workflow" );

			if( _context && _context.status != TaskStatus.STOPPED )
				throw new Error( "Attempt to run an already running workflow" );

			_delegate = new ChildTaskWatcher( this );
			var w : ITaskLiveCycleWatcher;

			if( !_contextFactory )
				_contextFactory = new ClassFactory( DefaultWorkflowContext );

			if( !_context )
			{
				_context = _contextFactory.newInstance() as IWorkflowContext;
			}

			_context.init( this, _contextDropIns );

			try
			{
				initialize();
			}
			catch( e : Error )
			{
				LOGGER.error( e.getStackTrace() );
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
				w.onTaskPhase( _rootTask, TaskPhase.DATA_SET );

			for each( w in _context.taskLiveCycleWatchers )
				w.onTaskPhase( _rootTask, TaskPhase.BEFORE_BEGIN );
			_rootTask.liveCycleDelegate = _delegate;
			var out : * = _rootTask.begin();

			if( !_rootTask.running )
			{
				return out;
			}
			else
			{
				for each( w in _context.taskLiveCycleWatchers )
					w.onTaskPhase( _rootTask, TaskPhase.AFTER_BEGIN );
				_retainedWorkflows[ this ] = this;
			}
		}

		public function set contextDropIns( inValue : Vector.<Object> ) : void
		{
			_contextDropIns = inValue;
		}


		protected function cleanup() : void
		{
			delete _retainedWorkflows[ this ];
			_rootTask.cleanUp();
			_context.status = TaskStatus.STOPPED;
			_context.suspendableFunctions.cleanUp();

			_context = null;
			_rootTask.releaseContext();
		}

		protected function initialize() : void
		{
			_rootTask.context = _context;
			_rootTask.initialize();

			if( _childNodes )
			{
				_context.configureObjects( _childNodes, this );
			}
		}

		protected function prepare() : void
		{
			_rootTask.prepare();
		}

		//--------------------------------- ROOT TASK DELEGATE ------------------------------------

		//TODO: check whether the livecycle watchers are called only once for root task
		INTERNAL function onRootTaskAbort( inTask : IWorkflowTask ) : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskPhase( _rootTask, TaskPhase.ABORTED );
			cleanup();
		}

		INTERNAL function onRootTaskBegin( inTask : IWorkflowTask ) : void
		{
		}

		INTERNAL function onRootTaskComplete( inTask : IWorkflowTask ) : void
		{
			dispatchEvent( new WorkflowEvent( WorkflowEvent.COMPLETED, _context, null, _rootTask.output ) );
			cleanup();
		}

		INTERNAL function onRootTaskFault( inTask : IWorkflowTask, inMessage : String ) : void
		{
			dispatchEvent( new WorkflowEvent( WorkflowEvent.FAULT, _context, null, inMessage ) );
			cleanup();
		}

		INTERNAL function onRootTaskInitialize( inTask : IWorkflowTask ) : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskPhase( _rootTask, TaskPhase.INITIALISED );
		}

		INTERNAL function onRootTaskPrepare( inTask : IWorkflowTask ) : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskPhase( _rootTask, TaskPhase.PREPARED );
		}

		INTERNAL function onRootTaskProgress( inTask : IWorkflowTask ) : void
		{
		}

		INTERNAL function onRootTaskResume( inTask : IWorkflowTask ) : void
		{
		}

		INTERNAL function onRootTaskSuspend( inTask : IWorkflowTask ) : void
		{
		}
	}
}
include "includes/WorkflowChildTaskWatcherInclude.as";
