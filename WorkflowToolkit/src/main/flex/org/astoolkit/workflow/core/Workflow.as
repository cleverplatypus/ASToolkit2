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
		private static const _ANNOTATIONS_INIT : Boolean = (function() : Boolean
		{
			AnnotationUtil.registerAnnotation( new ClassFactory( Featured ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( Template ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( TaskInput ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( AutoConfig ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( IteratorSource ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( TaskDescriptor ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( InjectPipeline ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( ManagedObject ) );
			Type.clearCache();
			return true;
		})();

		//----------------------------------- END OF STATIC ---------------------------------------

		private var _retainedWorkflows : Object = {};

		protected var _childNodes : Array;

		protected var _context : IWorkflowContext;

		protected var _contextFactory : IFactory;

		protected var _delegate : ITaskLiveCycleWatcher;

		protected var _inputFilter : Object;

		protected var _rootTask : IWorkflowTask;

		protected var _running : Boolean;

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
			_rootTask.liveCycleDelegate = _delegate;
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
			_context.suspendableFunctions.cleanUp();

			_context = null;
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

		INTERNAL function onRootTaskAbort( inTask : IWorkflowTask ) : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskAbort( _rootTask );
			cleanup();
		}

		INTERNAL function onRootTaskBegin( inTask : IWorkflowTask ) : void
		{
		}

		INTERNAL function onRootTaskComplete( inTask : IWorkflowTask ) : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskComplete( _rootTask );
			dispatchEvent( new WorkflowEvent( WorkflowEvent.COMPLETED, _context, null, _rootTask.output ) );
			cleanup();
		}

		INTERNAL function onRootTaskFault( inTask : IWorkflowTask, inMessage : String ) : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskFail( _rootTask, inMessage );
			dispatchEvent( new WorkflowEvent( WorkflowEvent.FAULT, _context, null, inMessage ) );
			cleanup();
		}

		INTERNAL function onRootTaskInitialize( inTask : IWorkflowTask ) : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskInitialize( _rootTask );
		}

		INTERNAL function onRootTaskPrepare( inTask : IWorkflowTask ) : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskPrepare( _rootTask );
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
import org.astoolkit.workflow.api.*;
import org.astoolkit.workflow.core.ExitStatus;
import org.astoolkit.workflow.core.Workflow;

namespace INTERNAL = "org.astoolkit.workflow.core.do::INTERNAL";

class ChildTaskWatcher implements ITaskLiveCycleWatcher
{
	private var _wf : Workflow;

	public function ChildTaskWatcher( inWorkflow : Workflow )
	{
		_wf  = inWorkflow;
	}

	public function afterTaskBegin( inTask : IWorkflowTask ) : void
	{
	}

	public function afterTaskDataSet( inTask : IWorkflowTask ) : void
	{
	}

	public function beforeTaskBegin( inTask : IWorkflowTask ) : void
	{
	}

	public function onBeforeContextUnbond( inTask : IWorkflowElement ) : void
	{
	}

	public function onContextBond( inElement : IWorkflowElement ) : void
	{
	}

	public function onDeferredTaskResume( inTask : IWorkflowTask ) : void
	{
	}

	public function onTaskAbort( inTask : IWorkflowTask ) : void
	{
		_wf.INTERNAL::onRootTaskAbort( inTask );
	}

	public function onTaskBegin( inTask : IWorkflowTask ) : void
	{
		_wf.INTERNAL::onRootTaskBegin( inTask );
	}

	public function onTaskComplete( inTask : IWorkflowTask ) : void
	{
		_wf.INTERNAL::onRootTaskComplete( inTask );
	}

	public function onTaskDeferExecution( inTask : IWorkflowTask ) : void
	{
	}

	public function onTaskExitStatus( inTask : IWorkflowTask, inStatus : ExitStatus ) : void
	{
	}

	public function onTaskFail( inTask : IWorkflowTask, inMessage : String ) : void
	{
		_wf.INTERNAL::onRootTaskFault( inTask, inMessage );
	}

	public function onTaskInitialize( inTask : IWorkflowTask ) : void
	{
		_wf.INTERNAL::onRootTaskInitialize( inTask );
	}

	public function onTaskPrepare( inTask : IWorkflowTask ) : void
	{
		_wf.INTERNAL::onRootTaskPrepare( inTask );
	}

	public function onTaskSuspend(inTask:IWorkflowTask ) : void
	{
		_wf.INTERNAL::onRootTaskSuspend( inTask );
	}

	public function onWorkflowCheckingNextTask( inWorkflow : ITasksGroup, inPipelineData:Object) : void
	{
	}

	public function get taskWatcherPriority() : int
	{
		return 0;
	}

	public function set taskWatcherPriority( inValue : int ) : void
	{
	}

	public function onTaskProgress(inTask:IWorkflowTask) : void
	{
		_wf.INTERNAL::onRootTaskProgress( inTask );
	}

	public function onTaskResume(inTask:IWorkflowTask) : void
	{
		_wf.INTERNAL::onRootTaskResume( inTask );
	}

}
