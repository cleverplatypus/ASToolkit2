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
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.collection.api.IRepeater;
	import org.astoolkit.commons.databinding.BindingUtility;
	import org.astoolkit.commons.factory.DynamicPoolFactoryDelegate;
	import org.astoolkit.commons.factory.PooledFactory;
	import org.astoolkit.commons.mapping.IPropertiesMapper;
	import org.astoolkit.commons.mapping.MappingError;
	import org.astoolkit.commons.reflection.AnnotationUtil;
	import org.astoolkit.commons.reflection.ClassInfo;
	import org.astoolkit.commons.reflection.IAnnotation;
	import org.astoolkit.workflow.annotation.*;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.constant.*;
	import org.astoolkit.workflow.internals.*;
	import org.astoolkit.workflow.ns.workflow_internal;
	
	[Event(
		name="subtaskInitialized",
		type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
		name="subtaskPrepared",
		type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
		name="subtaskStarted",
		type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
		name="subtaskDataSet",
		type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
		name="subtaskFault",
		type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
		name="subtaskCompleted",
		type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
		name="subtaskProgress",
		type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
		name="subtaskAborted",
		type="org.astoolkit.workflow.core.WorkflowEvent")]
	
	
	[Bindable]
	[DefaultProperty("children")]
	/**
	 * This is the core Workflow Toolkit class.
	 * <p>A <code>Workflow</code> instance represents a group of tasks
	 * executed either as a sequence or in parellel according to 
	 * <code>flow</code> property.</p>
	 * <p>Workflows can be iterated over an <code>IIterator</code> or
	 * in a infinite loop. The <code>dataProvider</code> property
	 * can be set to automatically set an <code>IIterator</code>
	 * that is instanciated if one supporting the <code>dataProvider</code>
	 * type is registered in the current context.</p>
	 */
	public class Workflow
		extends BaseTask 
		implements IWorkflow, IRepeater
	{
		use namespace workflow_internal;
		protected static const LOGGER : ILogger =
			Log.getLogger( getQualifiedClassName( Workflow ).replace(/:+/g, "." ) );
		
		private static var _metadataInitialized : Boolean;
		
		/**
		 * @private
		 * 
		 * holds a reference to the child task currently in its begin() function
		 */
		private var _executingTask : IWorkflowTask;
		
		/**
		 * @private
		 */ 
		protected var _root : IWorkflow;
		
		/**
		 * @private
		 */ 
		protected var _insert : Vector.<Insert>;
		
		/**
		 * @private
		 */ 
		protected var _childrenDelegate : IWorkflowDelegate;
		
		/**
		 * @private
		 */ 
		protected var _iterate : String = Iterate.ONCE;
		
		/**
		 * @private
		 */ 
		protected var _flow : String = Flow.SERIAL;
		
		/**
		 * @private
		 */ 
		protected var _feed : String = undefined;
		
		/**
		 * @private
		 */ 
		protected static var _retainedWorkflows : Object = [];
		
		/**
		 * @private
		 */ 
		protected var _subPipelineData : *;
		
		/**
		 * @private
		 */ 
		protected var _children : Vector.<IWorkflowElement> = new Vector.<IWorkflowElement>();
		
		/**
		 * @private
		 */ 
		protected var _contextFactory : IFactory;
		
		/**
		 * @private
		 * 
		 * the data source for this repeater's iteration.
		 */
		protected var _dataProvider : Object;
		
		/**
		 * @private
		 */ 
		protected var _iterator : IIterator;
		
		/**
		 * @private
		 */ 
		protected var _tasksIterator : IIterator;
		
		//============================ PUBLIC PROPERTIES =============================
		
		
		//============================ GETTERS/SETTERS =============================
		
		public function set iterator(inValue:IIterator):void
		{
			if( status != TaskStatus.RUNNING && status != TaskStatus.IDLE )
			{
				if( _iterator )
					_context.config.iteratorFactory.release( _iterator );
				_iterator = inValue;
			}
		}
		
		public function get iterator():IIterator
		{
			return _iterator;
		}
		
		protected function getIterator( inSource : Object) : IIterator
		{
			if( !_iterator )
				_iterator = _context.config.iteratorFactory.iteratorForSource( inSource );
			if( _iterator && _iterator.supportsSource( inSource ) )
			{
				_iterator.source = inSource;
				return _iterator;
			}
			return null;
		}
		
		[InjectPipeline]
		public function set dataProvider( inValue : Object ) : void
		{
			if( status == TaskStatus.RUNNING )
				return;
			_dataProvider = inValue;
		}
		
		public function get dataProvider() : Object
		{
			return _dataProvider;
		}
		
		
		[ArrayElementType("org.astoolkit.workflow.api.IWorkflowElement")]
		public function get children() : Vector.<IWorkflowElement>
		{
			return _children;   
		}
		
		public function set children( inChildren : Vector.<IWorkflowElement> ) : void
		{
			if( _children && _children.length > 0 )
				throw new Error( "Tasks list cannot be overridden" );
			_children = inChildren;
			for each( var child : IWorkflowElement in _children )
			child.parent = this;
		}
		
		/**
		 * @example Adding a logging task to an existing workflow.
		 * <listing version="3.0">
		 * &lt;wf:DoSomethingWorkflow
		 *     id=&quot;w_doSomethingWF&quot;
		 *     &gt;
		 *     &lt;wf:insert&gt;
		 *         &lt;Insert
		 *             parent=&quot;{ w_doSomethingWF }&quot;
		 *             relativeTo=&quot;{ w_doSomethingWF.t_sendMessage }&quot;
		 *             mode=&quot;after&quot;
		 *             &gt;
		 *             &lt;log:WriteLog
		 *                 level=&quot;info&quot;
		 *                 /&gt;
		 *         &lt;/Insert&gt;
		 *     &lt;/wf:insert&gt;
		 * &lt;/wf:DoSomethingWorkflow&gt;
		 * </listing>
		 * @inheritDoc
		 */
		public function set insert(inInsert: Vector.<Insert>):void
		{
			if( _insert )
				throw new Error( "insert cannot be redefined" );
			_insert = inInsert;
		}
		
		public function get insert():Vector.<Insert>
		{
			return _insert;
		}
		
		/**
		 * @inheritDoc 
		 */
		public function get iterate() : String
		{
			return _iterate;
		}
		
		[Inspectable( enumeration="once,loop,data")]
		public function set iterate( inIterate: String ) : void
		{
			_iterate = inIterate;
		}		
		
		public function get contextFactory() : IFactory
		{
			return _contextFactory;
		}
		
		public function set contextFactory( inFactory : IFactory ) : void
		{
			if( inFactory )
				_contextFactory = inFactory;
		}
		
		[Inspectable(defaultValue="serial", enumeration="parallel,serial,none")]
		public function set flow( inFlow : String ) : void
		{
			_flow = inFlow;
		}
		
		public function get flow():String
		{
			return _flow;
		}
		
		
		public function get feed() : String
		{
			return _feed;
		}
		
		[Inspectable(defaultValue="currentData", enumeration="pipeline,currentData")]
		public function set feed( inFeed : String ) : void
		{
			_feed = inFeed;
		}
		
		//============================ CONSTRUCTOR =============================
		public function Workflow()
		{
			super();
			_childrenDelegate = createDelegate();
			_feed = Feed.AUTO;
			_tasksIterator = new TasksIterator();
		}
		
		//============================ DELEGATE =============================
		
		protected function createDelegate() : IWorkflowDelegate
		{
			return new DefaultWorkflowDelegate( this );
		}
		
		protected function get runtimeTasks() : Vector.<IWorkflowTask>
		{
			return GroupUtil.getRuntimeTasks( _children );
		}
		
		protected function get runtimeElements() : Vector.<IWorkflowElement>
		{
			return GroupUtil.getRuntimeElements( _children );
		}
		
		
		/**
		 * @private
		 */
		workflow_internal function onSubtaskSuspended( inTask : IWorkflowTask ) : void
		{
			if( root.context.status != TaskStatus.SUSPENDED )
			{
				context.status = TaskStatus.SUSPENDED;
				context.dispatchEvent( new WorkflowEvent( WorkflowEvent.SUSPENDED, _context ) );
			}
			dispatchTaskEvent( WorkflowEvent.SUSPENDED, inTask );
		}
		
		/**
		 * @private
		 */
		workflow_internal function onSubtaskResumed( inTask : IWorkflowTask ) : void
		{
			if( context.status == TaskStatus.SUSPENDED )
			{
				context.status = TaskStatus.RUNNING;
				context.dispatchEvent( new WorkflowEvent( WorkflowEvent.RESUMED, _context ) );
			}
			dispatchTaskEvent( WorkflowEvent.RESUMED, inTask );
		}
		
		/**
		 * @private
		 */
		workflow_internal function onSubtaskBegin( inTask : IWorkflowTask ) : void
		{
			dispatchTaskEvent( WorkflowEvent.STARTED, inTask );
		}
		
		/**
		 * @private
		 */
		workflow_internal function onSubtaskProgress( inTask : IWorkflowTask ) : void
		{
			if( inTask.status == TaskStatus.SUSPENDED )
				return;
			dispatchTaskEvent( WorkflowEvent.PROGRESS, inTask );
		}
		
		/**
		 * @private
		 */
		workflow_internal function onSubtaskPrepared( inTask : IWorkflowTask ) : void
		{
			dispatchTaskEvent( WorkflowEvent.PREPARED, inTask );
		}
		
		/**
		 * @private
		 */
		workflow_internal function onSubtaskInitialized( inTask : IWorkflowTask ) : void
		{
			dispatchTaskEvent( WorkflowEvent.INITIALIZED, inTask );
		}
		
		/**
		 * @private
		 */
		workflow_internal function onSubtaskAbort( inTask : IWorkflowTask, inMessage : String ) : void
		{
			dispatchTaskEvent( WorkflowEvent.ABORTED, inTask, inMessage );
			onSubtaskCompleted( inTask );
		}
		
		/**
		 * @private
		 */
		workflow_internal function onSubtaskFault( inTask : IWorkflowTask, inMessage : String ) : void
		{
			if( inTask.status != TaskStatus.ABORTED )
			{
				if( inTask.failurePolicy == FailurePolicy.ABORT )
				{
					LOGGER.error( 
						"Task {0}:\"{1}\" failed. Reason: {2} \nData:\n{3}", 
						inTask.description, getQualifiedClassName( inTask ),
						inMessage,
						_subPipelineData
					);
					dispatchTaskEvent( WorkflowEvent.FAULT, inTask, inMessage );
					if( _parent != null )
						abort();
					else
						complete();
				}
				else if( inTask.failurePolicy == FailurePolicy.SUSPEND )
				{
					inTask.suspend();
					onSubtaskCompleted( inTask );
				}
				else if( inTask.failurePolicy == FailurePolicy.CASCADE )
				{
					fail( "Subtask {0} failed with message:\n{1}", inTask.description, inMessage );
					return;
				}
				else if( inTask.failurePolicy == FailurePolicy.CONTINUE )
				{
					if( iterate == Iterate.DATA || iterator )
					{
						nextData();
						prepareChildren();
						onSubtaskCompleted( inTask );
					}
					else
						complete();
				}
				else if( inTask.failurePolicy.match( /^log\-/ ) )
				{
					LOGGER[ inTask.failurePolicy.replace( /^log\-/, "" ) ]( 
						"Task " + inTask.description + " failed with message:\n" + inMessage );
					onSubtaskCompleted( inTask );
				}
				else
					onSubtaskCompleted( inTask );
			}
		}
		
		workflow_internal function onSubtaskCompleted( inTask : IWorkflowTask ) : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskExitStatus( inTask, inTask.exitStatus );
			if( inTask == this )
			{
				if( !_parent && 
					outlet is IPropertiesMapper && 
					IPropertiesMapper( outlet ).hasTarget() )
				{
					var mappedA : * = IPropertiesMapper( inTask.outlet ).map( inTask.output );
					if( mappedA != undefined )
						_pipelineData = mappedA;				
				}
				dispatchTaskEvent( WorkflowEvent.COMPLETED, inTask, _pipelineData );
				return;
			}
			if( inTask != this && _status == TaskStatus.ABORTED )
			{
				complete();
				return;
			}
			if( inTask.status != TaskStatus.ABORTED )
			{
				dispatchTaskEvent( WorkflowEvent.COMPLETED, inTask, _pipelineData );
				if( inTask.outlet != CLOSED_OUTLET )
				{
					if( !inTask.exitStatus.interrupted )
					{
						if( inTask.outlet == PIPELINE_OUTLET ) 
							_subPipelineData = inTask.output;
						else if( inTask.outlet is String )
						{
							var sOutlet : String = inTask.outlet as String;
							if( sOutlet.match( /^\$\w+$/ ) )
							{
								context.variables[ ( inTask.outlet as String).substr(1) ] = inTask.output;
							}
							else if( sOutlet.match( /^\|?\w+$/ ) )
							{
								try
								{
									if( sOutlet.charAt( 0 ) == "|" )
										_subPipelineData[ sOutlet.substr(1) ] = inTask.output;
									else
										inTask.filteredPipelineData[ sOutlet ] = inTask.output
								}
								catch( e : Error )
								{
									fail( "Injecting task {0} output failed. {1} class doesn't have " +
										"the \"{2}\" property.",
										inTask.description,
										(sOutlet.charAt( 0 ) == "|" ? _subPipelineData : inTask.filteredPipelineData ),
										sOutlet.replace( /^|/, "" ) );
									return;
								}
							}
						}
						else if( inTask.outlet is IPropertiesMapper )
						{
							var mapped : *;
							try {
								mapped = IPropertiesMapper( inTask.outlet ).map( inTask.output );
							}
							catch( e : Error )
							{
								var cause : String = 
									e is MappingError ? e.message : e.getStackTrace();
								fail( "Output mapping for {0} failed.\nCause:\n{1}", inTask.description, cause );
								return;
							}
							if( mapped != undefined )
								_subPipelineData = mapped;
						}
						else if( inTask.outlet != CLOSED_OUTLET )
						{
							_subPipelineData = inTask.outlet;
						}
					}
				}
			}
			if( inTask != _executingTask )
			{
				if( _flow == Flow.SERIAL && _tasksIterator.hasNext() )
				{
					runNextTask();
					return;
				}
				else
				{
					if( !_tasksIterator.hasNext() )
					{
						complete();
					}
				}
			}
		}
		
		//============================ LIFE CYCLE =============================
		
		override public function initialize() : void
		{
			if( _status != TaskStatus.STOPPED )
				return;
			if( !_metadataInitialized )
				initializeMetadata();
			super.initialize();
			_tasksIterator.source = this;
			
			if( children )
			{
				for each( var element : IWorkflowElement in children.concat( GroupUtil.getInserts( this ) ) )
				{
					element.delegate = _childrenDelegate;
					element.context = _context;
					element.parent = this;
					element.initialize();
				}
			}
		}
		
		override public function prepare() : void
		{
			super.prepare();
			if( _iterator )
				_iterator.reset();
			_tasksIterator.reset();
			prepareChildren();
		}
		
		public function run( inTaskInput : * = undefined ) : *
		{
			if( inTaskInput != undefined )
				_pipelineData = inTaskInput;
			_delegate = createDelegate();
			var w : ITaskLiveCycleWatcher;
			if( !_contextFactory )
				_contextFactory = new ClassFactory( DefaultWorkflowContext );
			if( !_context )
			{
				_context = _contextFactory.newInstance() as IWorkflowContext;
			}
			_context.init();
			for each( w in _context.taskLiveCycleWatchers )
				w.onContextBound( this );
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
			var c : IWorkflowContext = _context;
			for each( w in _context.taskLiveCycleWatchers )
			w.beforeTaskBegin( this );
			begin();
			for each( w in c.taskLiveCycleWatchers )
			w.afterTaskBegin( this );
			if( !running )
			{
				return _pipelineData;
			}
			else
			{
				_retainedWorkflows[ this ] = this;
				
			}
		}
		
		/**
		 * Execution entry point for the workflow.
		 * You don't have to call this method yourself
		 */
		override public function begin() : void
		{
			if(!_context )
			{
				throw new Error( "This workflow is not initialized properly." +
					"You might want to call run() instead of begin()" );
			}
			super.begin();
			_subPipelineData = UNDEFINED;
			var w : ITaskLiveCycleWatcher;
			if( runtimeTasks == null || runtimeTasks.length == 0 )
			{
				LOGGER.warn( "Workflow {0} has no tasks to perform", _description );
				complete();
				return;
			}
			try
			{
				//setting iterate to Iterate.DATA automatically if dataProvider wasn't injected
				if( _dataProvider && _actuallyInjectableProperties.indexOf( "dataProvider" ) == -1 )
				{
					_iterate = Iterate.DATA;
					LOGGER.info( "Setting iterate=\"data\" as dataProvider has been" +
						"set explicitly" );
				}
				if( _iterate == Iterate.DATA || iterator )
				{
					var currentIterator : IIterator = iterator;
					if( !currentIterator )
					{
						if( _dataProvider )
							currentIterator = getIterator( _dataProvider );
						else
							currentIterator = getIterator( filteredPipelineData );
					}
					if( currentIterator != null &&  currentIterator.hasNext() )
					{
						//_dataProvider = filteredPipelineData;
						nextData();
						prepareChildren();

					}
					else
					{	
						if( !currentIterator )
						{
							fail( "Workflow \"{0}\" failed because" +
								" no data iterator was found for type {1}", 
								description,
								getQualifiedClassName( _dataProvider != null ? _dataProvider : filteredPipelineData )
							);
							return;
						}
						else
							LOGGER.info( "Workflow \"{0}\" completes with no data", description);
						complete();
						if( !_parent )
							for each( w in _context.taskLiveCycleWatchers )
							w.afterTaskBegin( this );
						return;
					}
				}
				else if( _iterate == Iterate.LOOP )
				{
					if( !getIterator( null ) )
					{
						fail( "Workflow \"{0}\" failed because" +
							" no loop iterator was found for type", 
							description
						);
						return;
					}
					nextData();
					prepareChildren();

				}
				else
				{
					prepareChildren();
				}
				//GroupUtil.overrideChildrenProperties( this, _overriddenProperties );
				runNextTask();
			} 
			catch( e : Error )
			{
				fail( e.getStackTrace() );
				return;
			}
		}
		
		override protected function complete( inOutputData : * = undefined ) : void
		{
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskComplete( this );
			var wasAborted : Boolean = _status == TaskStatus.ABORTED;
			if( wasAborted )
				return;
			if( _iterate != Iterate.ONCE || iterator )
			{
				//_iterator != null otherwise begin() would have failed
				LOGGER.debug(
					"Workflow '{0}' task iteration completed with index {1}", 
					description, 
					_iterator.currentIndex() );
				if( !_iterator.isAborted && _iterator.hasNext() )
				{
					nextData();
					prepareChildren();
					runNextTask();
					return;
				}
			}
			if( _outlet != CLOSED_OUTLET )
				_pipelineData = _subPipelineData;
			super.complete( _pipelineData );
			if( _iterate == Iterate.DATA && _dataProvider != null  )
			{
				if ( _actuallyInjectableProperties.indexOf( "dataProvider" ) > -1 )
				{
					_dataProvider = null;
				}
			}
			if( _iterator )
				_context.config.iteratorFactory.release( _iterator );
			if( !_parent )
				cleanUp();
			
		}
		
		override protected function fail(inMessage:String, ...inRest):void
		{
			var c : IWorkflowContext = _context;
			super.fail( inMessage, inRest );
			if( _iterator )
				c.config.iteratorFactory.release( _iterator );
			if( !_parent )
			{
				for each( var w : ITaskLiveCycleWatcher in c.taskLiveCycleWatchers )
				w.onTaskFail( this );
				cleanUp();
			}
		}
		
		override public function cleanUp() : void
		{
			var aContext : IWorkflowContext = _context; //super.cleanup() makes _context == null
			super.cleanUp();
			if ( _actuallyInjectableProperties.indexOf( "dataProvider" ) > -1 )
			{
				_dataProvider = null;
			}
			for each( var child : IWorkflowElement in runtimeTasks )
			{
				child.cleanUp();
			}
			if( this == _root )
			{
				aContext.cleanup();
				delete _retainedWorkflows.hasOwnProperty[_root];
			}
		}
		
		//============================ INTERNALS =============================
		
		protected function prepareChildren() : void
		{
			for each( var element : IWorkflowElement in runtimeElements )
			{
				element.delegate = _childrenDelegate;
				element.currentIterator = _iterator;
				element.prepare();
			}
		}
		
		/**
		 * @private
		 */
		protected function nextData() : void
		{
			_subPipelineData = UNDEFINED;
			_tasksIterator.reset();
			if( _iterator )
			{
				_iterator.next();
			}
		}
		
		protected function runSubTask( inTask : IWorkflowTask, inNow : Boolean = false ) : void
		{
			if( _status == TaskStatus.SUSPENDED ) {
				_context.suspendableFunctions.addResumeCallBack( 
					function() : void 
					{
						runSubTask( inTask, inNow );
					} );
				return;
			}
			if( inNow || inTask.delay == 0 )
			{
				var w : ITaskLiveCycleWatcher;
				try {
					if( inTask is IWorkflow && IWorkflow( inTask ).contextFactory == null )
						IWorkflow( inTask ).contextFactory = _contextFactory;
					_executingTask = inTask;
					inTask.begin();
					if( _status != TaskStatus.RUNNING )
						return;
				}
				catch( taskError : Error )
				{
					_childrenDelegate.onFault(
						inTask, 
						taskError.getStackTrace() 
					);
					return;
				}
				_executingTask = null;
				for each( w in _context.taskLiveCycleWatchers )
					w.afterTaskBegin( inTask );
				
			}
			else
			{
				setTimeout( runSubTask, inTask.delay, inTask, true );
			}
		}
		
		protected function setSubtaskPipelineData( inTask : IWorkflowTask ) : void
		{
			if( _subPipelineData == UNDEFINED )
			{
				if( _feed == Feed.PIPELINE ||
					( _feed == Feed.AUTO && _dataProvider == null ) )
				{
					_subPipelineData = filteredPipelineData;
				}
				else if( _feed == Feed.CURRENT_DATA ||
					( _feed == Feed.AUTO && _dataProvider != null ) )
				{
					_subPipelineData = _iterator.current();
				}
			}
			
			if( inTask.output == UNDEFINED )
			{
				if( inTask.inlet is String )
				{
					try
					{
						if( Object( inTask ).hasOwnProperty( inTask.inlet ) )
						{
							if( inTask[ inTask.inlet ] is Function )
							{
								var f : Function = inTask[ inTask.inlet ] as Function; 
								f.apply( inTask, [ _subPipelineData ] );
							}
							else
								inTask[ inTask.inlet ] = _subPipelineData;
						}
					}
					catch( e : Error )
					{
						throw new Error( "Error while trying to set pipeline data to  " +
							"task's property/function '" + inTask.inlet + "'\n\n" + 
							e.getStackTrace() );
					}
				}
				else if( inTask.inlet is Object ) 
				{
					try
					{
						for( var k : String in inTask.inlet )
						{
							inTask[ k ] = inTask.filteredPipelineData[ inTask.inlet[ k ] ];
						}
					}
					catch( e : Error )
					{
						throw new Error( "Error while trying to map pipeline " +
							"data properties to task properties.\n\n" + e.getStackTrace() );
					}
				}
				
				inTask.input = _subPipelineData;
			}
		}
		protected function checkPipelineStatus( inTask : IWorkflowTask ) : String
		{
			if( _subPipelineData == EMPTY_PIPELINE && inTask.invalidPipelinePolicy == InvalidPipelinePolicy.FAIL )
			{
				fail( "Empty pipeline in task '" + description + "' (" + getQualifiedClassName( inTask ) + ")" );
				return InvalidPipelinePolicy.FAIL;
			}
			var constraints : Vector.<IAnnotation> = 
				ClassInfo.forType( inTask )
				.getAnnotationsOfType( TaskInput );
			if( !constraints || constraints.length == 0 )
				return InvalidPipelinePolicy.IGNORE;
			var data : Object = _subPipelineData;
			for each( var type : String in constraints[0].getArray() )
			{
				if( getQualifiedClassName( data ).replace( /:+/g, "." ) ==
					type.replace( /:+/g, "." ) )
					return InvalidPipelinePolicy.IGNORE;
			}
			if( inTask.invalidPipelinePolicy == InvalidPipelinePolicy.FAIL )
				fail( "Unexpected taskInput type \"{0}\":  for task {1}. Expected type: {2}",
					getQualifiedClassName( _subPipelineData ),
					inTask.description,
					constraints[0].getArray().join( " or " ) );
			
			return inTask.invalidPipelinePolicy;
		}
		
		protected function runNextTask() : void
		{
			
			//if( _nextTaskIndex == runtimeTasks.length )
			if( !_tasksIterator.hasNext() )
			{
				if( flow == Flow.SERIAL ) 
					complete();
				return;
			}
			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onWorkflowCheckingNextTask( this, _subPipelineData );
			var task : IWorkflowTask;
			while( _status != TaskStatus.ABORTED &&
				_tasksIterator.hasNext() )
			{
				task = _tasksIterator.next() as IWorkflowTask;
				for each( w in _context.taskLiveCycleWatchers )
					w.beforeTaskBegin( task );
				setSubtaskPipelineData( task );
				triggerContextBindings();
				switchBindingOnWrappingGroups( task, true );
				BindingUtility.firePropertyBinding( task.document, task, "enabled" );
				var taskEnabled : Boolean = 
					GroupUtil.getOverrideSafeValue( 
						task, 
						"enabled"
						);
				if( taskEnabled )
				{
					var pipelineStatus : String = checkPipelineStatus( task );
					if( pipelineStatus == InvalidPipelinePolicy.SKIP )
						continue;
					else if( pipelineStatus == InvalidPipelinePolicy.FAIL ) 
					{
						return;
					}
					else
					{
						LOGGER.debug( "Pipeline checks passed or ignored for task {0}", task.description );
					}
					dispatchTaskEvent( WorkflowEvent.DATA_SET, task, task.output );
					runSubTask( task );
					switchBindingOnWrappingGroups( task, false );
					if( task.exitStatus && task.exitStatus.interrupted )
						return;
					if( _status != TaskStatus.RUNNING )
						return;
					if( task.running && _flow != Flow.PARALLEL )
						return;
				}
			}
			complete();
		}
		
		private function switchBindingOnWrappingGroups( inTask : IWorkflowTask, inEnable : Boolean ) : void
		{
			var p : IElementsGroup = inTask.parent;
			while( !( p is IWorkflow ) )
			{
				if( inEnable )
					BindingUtility.enableAllBindings( p.document, p );
				else
					BindingUtility.disableAllBindings( p.document, p );
				p = p.parent;
			}
		}
		
		private function initializeMetadata() : void
		{
			AnnotationUtil.registerAnnotation( new ClassFactory( TaskInput ) );
			AnnotationUtil.registerAnnotation( 
				PooledFactory.create( 
					InjectPipeline, 
					new DynamicPoolFactoryDelegate( createInjectPipeline ) ) );
			AnnotationUtil.registerAnnotation( new ClassFactory( OverrideChildrenProperty ) );
			ClassInfo.clearCache();
		}
		
		private function createInjectPipeline( inType : Class, inProperties : Object ) : InjectPipeline
		{
			return new InjectPipeline( _context.config.inputFilterRegistry );
		}
		
		private function triggerContextBindings() : void
		{
			IEventDispatcher( _document ).dispatchEvent(
				new PropertyChangeEvent(
					PropertyChangeEvent.PROPERTY_CHANGE,
					false,
					false,
					PropertyChangeEventKind.UPDATE,
					"$",
					Math.random(),
					context.variables
				) );
			
		}
	}
}