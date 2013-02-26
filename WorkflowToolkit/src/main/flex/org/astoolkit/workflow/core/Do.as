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

	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;

	import mx.core.IFactory;
	import mx.logging.ILogger;

	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.collection.api.IRepeater;
	import org.astoolkit.commons.databinding.BindingUtility;
	import org.astoolkit.commons.mapping.MappingError;
	import org.astoolkit.commons.mapping.SimplePropertiesMapper;
	import org.astoolkit.commons.mapping.api.IPropertiesMapper;
	import org.astoolkit.commons.mapping.api.IPropertiesMapperFactory;
	import org.astoolkit.commons.mapping.api.IPropertyMappingDescriptor;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.commons.process.api.IDeferrableProcess;
	import org.astoolkit.commons.utils.Range;
	import org.astoolkit.commons.utils.getLogger;
	import org.astoolkit.workflow.annotation.*;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.constant.*;
	import org.astoolkit.workflow.internals.*;

	/**
	 * This is one of the core Workflow Toolkit's classes.
	 *
	 * <p>A <code>TasksGroup</code> (<b>Do</b> node) represents a group of tasks executed either as a sequence or in
	 * parellel according to <code>flow</code> property.</p>
	 * <p>They can iterate over an <code>IIterator</code> or in a infinite loop.
	 * The <code>dataProvider</code> property can be set to any value for which a
	 * <code>IIterator</code> is registered in the context. Built-in iterators are available
	 * for Flex SDK's list classes, i.e. <code>Array, Vector, IList, ByteArray, FileStream,
	 * XMLList</code>.</p>
	 *
	 */
	public class Do extends BaseTask implements ITasksGroup, IRepeater
	{
		use namespace astoolkit_private;

		protected static const LOGGER : ILogger = getLogger( Do );

		private var _elementsQueue : ElementsQueue;

		/**
		 * @private
		 *
		 * holds a reference to the child task currently in its begin() function
		 */
		private var _executingTask : IWorkflowTask;

		/**
		 * @private
		 */
		protected var _childNodes : Array;

		/**
		 * @private
		 */
		protected var _children : Vector.<IWorkflowElement> = new Vector.<IWorkflowElement>();

		/**
		 * @private
		 */
		protected var _childrenDelegate : ITaskLiveCycleWatcher;

		/**
		 * @private
		 */
		protected var _contextAwareElements : Vector.<IContextAwareElement>;

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
		protected var _feed : String = undefined;

		/**
		 * @private
		 */
		protected var _flow : String = Flow.SERIAL;

		/**
		 * @private
		 */
		protected var _insert : Vector.<Insert>;

		/**
		 * @private
		 */
		protected var _iterate : String = Iterate.ONCE;

		/**
		 * @private
		 */
		protected var _iterator : IIterator;

		/**
		 * @private
		 */
		protected var _iteratorConfig : Object;

		/**
		 * @private
		 */
		protected var _root : ITasksGroup;

		/**
		 * @private
		 */
		protected var _subPipelineData : *;

		public function get children() : Vector.<IWorkflowElement>
		{
			return _children;
		}

		[AutoAssign]
		/**
		 * the tasks to execute
		 */
		public function set children( inChildren : Vector.<IWorkflowElement> ) : void
		{
			_children = inChildren;

			for each( var child : IWorkflowElement in _children )
				child.parent = this;
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

		public function get dataProvider() : Object
		{
			return _dataProvider;
		}

		[InjectPipeline]
		public function set dataProvider( inValue : Object ) : void
		{
			_onPropertySet( "dataProvider" );

			if( status == TaskStatus.RUNNING )
				return;
			_dataProvider = inValue;
		}

		public function get feed() : String
		{
			return _feed;
		}

		[Inspectable( defaultValue = "auto", enumeration = "auto,pipeline,currentData" )]
		public function set feed( inFeed : String ) : void
		{
			_feed = inFeed;
		}

		public function get flow() : String
		{
			return _flow;
		}

		[Inspectable( defaultValue = "serial", enumeration = "parallel,serial" )]
		public function set flow( inFlow : String ) : void
		{
			_flow = inFlow;
		}

		/**
		 * @inheritDoc
		 */
		public function get iterate() : String
		{
			return _iterate;
		}

		[Inspectable( enumeration = "once,loop,data" )]
		public function set iterate( inIterate : String ) : void
		{
			_iterate = inIterate;
		}

		public function get iterator() : IIterator
		{
			return _iterator;
		}

		[AutoAssign( type = "org.astoolkit.commons.collection.api.IIterator" )]
		public function set iterator( inValue : IIterator ) : void
		{
			_onPropertySet( "iterator" );

			if( status != TaskStatus.RUNNING && status != TaskStatus.IDLE )
			{
				if( _iterator )
					_context.config.iteratorFactory.release( _iterator );
				_iterator = inValue;
			}
		}

		public function set iteratorConfig( inValue : Object ) : void
		{
			_onPropertySet( "iteratorConfig" );
			_iteratorConfig = inValue;
		}

		public function Do()
		{
			super();
			_childrenDelegate = new ChildTaskWatcher( this );
			_feed = Feed.AUTO;
		}

		/**
		 * @inheritDoc
		 */
		override public function abort() : void
		{
			LOGGER.debug( "abort() '{0}' ({1})", description, getQualifiedClassName( this ) );
			_status = TaskStatus.ABORTED;

			if( !_exitStatus )
				exitStatus = new ExitStatus( ExitStatus.ABORTED );
			_thread++;

			//REMOVE: dispatchTaskEvent( WorkflowEvent.ABORTED, this );

			for each( var element : IWorkflowElement in _childNodes )
				if( element is IWorkflowTask )
					IWorkflowTask( element ).abort();

			if( _delegate )
				_delegate.onTaskPhase( this, TaskPhase.ABORTED );

			if( !_parent )
				cleanUp();
		}

		/**
		 * Execution entry point for the workflow.
		 * You don't have to call this method yourself
		 */
		override public function begin() : void
		{
			if( !_context )
			{
				throw new Error( "This tasks group not initialized properly." +
					"Note: begin() cannot be invoked directly." );
			}
			super.begin();
			_subPipelineData = _inputData === undefined ? UNDEFINED : _inputData;

			try
			{
				//setting iterate to Iterate.DATA automatically if dataProvider wasn't injected
				if( _dataProvider && propertyWasSetExplicitly( "dataProvider" ) ||
					_iterator && propertyWasSetExplicitly( "iterator" ) )
				{
					_iterate = Iterate.DATA;
					LOGGER.info( "Setting iterate=\"data\" as dataProvider has been" +
						"set explicitly" );
				}

				setupIterator();

				if( !_iterator )
				{
					fail( "Flow \"{0}\" failed because" +
						" no data iterator was found for type {1}",
						description,
						getQualifiedClassName(
						_dataProvider != null ?
						_dataProvider :
						filteredInput ) );
					return;
				}

				if( _iterator.hasNext() )
				{
					processIteration();
				}
				else
				{
					LOGGER.info(
						"Flow \"{0}\" completes with no data",
						description );
					completeGroup();
					return;
				}
			}
			catch( e : Error )
			{
				fail( e.getStackTrace() );
				return;
			}
		}

		public function childNodeAdded( inNode : Object ) : void
		{
			if( !_childNodes )
				_childNodes = [];
			_childNodes.push( inNode );

			if( _context )
				_context.configureObjects( [ inNode ], this );

		}

		override public function cleanUp() : void
		{
			super.cleanUp();

			if( !propertyWasSetExplicitly( "dataProvider" ) )
			{
				_dataProvider = null;
			}

			if( !propertyWasSetExplicitly( "iterator" ) )
			{
				_context.config.iteratorFactory.release( _iterator );
				_iterator = null;
			}

			for each( var child : IWorkflowElement in _children )
			{
				child.cleanUp();
			}
		}

		override public function releaseContext() : void
		{
			super.releaseContext();

			for each( var child : IWorkflowElement in _children )
			{
				child.releaseContext();
			}
		}

		override public function initialize() : void
		{
			if( _status != TaskStatus.STOPPED )
				return;
			super.initialize();

			if( _childNodes )
			{
				_context.configureObjects( _childNodes, _document );
			}

			if( _children )
			{
				for each( var element : IWorkflowElement in _children )
				{
					//TODO: review this as some assignments could be redundant
					element.liveCycleDelegate = _childrenDelegate;
					element.context = _context;
					element.parent = this;
					element.initialize();
				}
			}

			for each( var cae : IContextAwareElement in _contextAwareElements )
			{
				cae.context = _context;
			}
			_elementsQueue = new ElementsQueue( _children );
		}

		override public function prepare() : void
		{
			super.prepare();

			if( _iterator )
				_iterator.reset();

		}

		protected function completeGroup() : void
		{
			if( _status == TaskStatus.ABORTED )
				return;

			/*for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskComplete( this );*/

			if( !_ignoreOutput )
				_pipelineData = _subPipelineData;

			if( _iterate == Iterate.DATA && _dataProvider != null )
			{
				if( !propertyWasSetExplicitly( "dataProvider" ) )
					_dataProvider = null;
			}

			if( !propertyWasSetExplicitly( "iterator" ) )
			{
				_context.config.iteratorFactory.release( _iterator );
				_iterator = null;
			}
			complete( _pipelineData );
		}

		override protected function fail( inMessage : String, ... inRest ) : void
		{
			var c : IWorkflowContext = _context;
			super.fail( inMessage, inRest );

			if( _iterator )
				c.config.iteratorFactory.release( _iterator );
		}

		/**
		 * @private
		 */
		protected function nextData() : void
		{
			_subPipelineData = UNDEFINED;
			_elementsQueue.init();

			if( _iterator )
			{
				_iterator.next();
			}
		}

		/**
		 * @private
		 */
		INTERNAL function onSubtaskAbort( inTask : IWorkflowTask ) : void
		{
			//REMOVE: dispatchTaskEvent( WorkflowEvent.ABORTED, inTask );
			INTERNAL::onSubtaskCompleted( inTask );
		}

		/**
		 * @private
		 */
		INTERNAL function onSubtaskBegin( inTask : IWorkflowTask ) : void
		{
			//REMOVE: dispatchTaskEvent( WorkflowEvent.STARTED, inTask );
		}

		INTERNAL function onSubtaskCompleted( inTask : IWorkflowTask ) : void
		{

			if( _status == TaskStatus.ABORTED )
			{
				completeGroup();
				return;
			}

			if( inTask.status != TaskStatus.ABORTED )
			{
				//REMOVE: dispatchTaskEvent( WorkflowEvent.COMPLETED, inTask, _pipelineData );

				if( !_ignoreOutput )
				{
					if( !inTask.exitStatus || !inTask.exitStatus.interrupted )
					{
						if( inTask.outlet == PIPELINE_OUTLET && flow != Flow.PARALLEL )
							_subPipelineData = inTask.output;
						else if( inTask.outlet is String )
						{
							var sOutlet : String = inTask.outlet as String;

							//TODO: reimplement using IExpressionResolver
							if( sOutlet.match( /^\$?\w+$/ ) )
								context.variables[ inTask.outlet ] = inTask.output;
							else if( sOutlet.match( /^\.?\w+$/ ) )
							{
								//TODO: change this to use an outputFilter ???
								try
								{
									if( sOutlet.charAt( 0 ) == "." )
										//output is set as a property of the unmodified pipelineData passed
										//to this task. The property name is the outlet text after "|"
										_subPipelineData[ sOutlet.substr( 1 ) ] = inTask.output;
									else
										//output is set as the [ outlet ] property of the input object (after filtering)
										inTask.filteredInput[ sOutlet ] = inTask.output
								}
								catch( e : Error )
								{
									fail( "Injecting task {0} output failed. {1} class doesn't have " +
										"the \"{2}\" property.",
										inTask.description,
										( sOutlet.charAt( 0 ) == "." ? _subPipelineData : inTask.filteredInput ),
										sOutlet.replace( /^\./, "" ) );
									return;
								}
							}
						}
						else if( inTask.outlet is IPropertiesMapperFactory ||
							inTask.outlet is IPropertiesMapper )
						{
							var localMapper : IPropertiesMapper;

							if( inTask.outlet is IPropertiesMapperFactory )
								localMapper =
									IPropertiesMapperFactory( inTask.outlet ).getInstance();
							else
								localMapper = IPropertiesMapper( inTask.outlet )
							var mapped : *;

							try
							{
								mapped = localMapper.map( inTask.output );
							}
							catch( e : Error )
							{
								var cause : String =
									e is MappingError ? e.message : e.getStackTrace();
								fail( "Output mapping for {0} failed.\nCause:\n{1}", inTask.description, cause );
								return;
							}

							if( mapped !== undefined && flow != Flow.PARALLEL )
								_subPipelineData = mapped;
						}
						else if( inTask.outlet is IPropertyMappingDescriptor )
						{
							//TODO: cache property mapping
							var descriptor : IPropertyMappingDescriptor =
								IPropertyMappingDescriptor( inTask.outlet );
							var mapper : SimplePropertiesMapper = new SimplePropertiesMapper();
							mapper.strict = descriptor.strict;
							mapper.transformerRegistry = _dataTransformerRegistry;
							var target : Object =
								descriptor.getTarget() !== undefined ?
								descriptor.getTarget() : {};
							_subPipelineData = mapper.mapWith(
								inTask.output,
								descriptor.getMapping(),
								target );
						}
						else if( !inTask.ignoreOutput && flow != Flow.PARALLEL )
						{
							_subPipelineData = inTask.outlet;
						}
					}
				}
			}

			/*
			if inTask == _executingTask
			it means that the task has completed synchronously.
			Therefore the next task will be processed inside
			the synchronous loop in runNextTask()
			*/
			if( inTask != _executingTask )
			{
				if( _flow == Flow.SERIAL && _elementsQueue.hasNext() )
				{
					resumeProcessIteration();
					return;
				}
				else
				{
					if( !_iterator.hasNext() && !_elementsQueue.hasPendingElements() )
					{
						completeGroup();
					}
				}
			}
		}

		/**
		 * @private
		 */
		INTERNAL function onSubtaskFault( inTask : IWorkflowTask, inMessage : String ) : void
		{
			if( inTask.status != TaskStatus.ABORTED )
			{
				LOGGER.debug( "Subtask fault: {0}", inMessage );

				//REMOVE: dispatchTaskEvent( WorkflowEvent.FAULT, inTask, inMessage );

				if( inTask.failurePolicy == FailurePolicy.ABORT )
				{
					abort();
					return;
				}
				else if( inTask.failurePolicy == FailurePolicy.SUSPEND )
				{
					inTask.suspend();
					INTERNAL::onSubtaskCompleted( inTask );
				}
				else if( inTask.failurePolicy == FailurePolicy.CASCADE )
				{
					fail( "Subtask {0} failed with message:\n{1}", inTask.description, inMessage );
					return;
				}
				else if( inTask.failurePolicy == FailurePolicy.CONTINUE )
				{
					nextData();
					prepareChildren();
					INTERNAL::onSubtaskCompleted( inTask );
				}
				else if( inTask.failurePolicy.match( /^log\-/ ) )
				{
					//TODO: Log
					INTERNAL::onSubtaskCompleted( inTask );
				}
				else
					INTERNAL::onSubtaskCompleted( inTask );
			}
		}

		/**
		 * @private
		 */
		INTERNAL function onSubtaskInitialized( inTask : IWorkflowTask ) : void
		{
			//REMOVE: dispatchTaskEvent( WorkflowEvent.INITIALIZED, inTask );
		}

		/**
		 * @private
		 */
		INTERNAL function onSubtaskPrepared( inTask : IWorkflowTask ) : void
		{
			//REMOVE: dispatchTaskEvent( WorkflowEvent.PREPARED, inTask );
		}

		/**
		 * @private
		 */
		INTERNAL function onSubtaskProgress( inTask : IWorkflowTask ) : void
		{
			if( inTask.status == TaskStatus.SUSPENDED )
				return;
			//REMOVE: dispatchTaskEvent( WorkflowEvent.PROGRESS, inTask );
		}

		/**
		 * @private
		 */
		INTERNAL function onSubtaskResumed( inTask : IWorkflowTask ) : void
		{
			if( context.status == TaskStatus.SUSPENDED )
			{
				context.status = TaskStatus.RUNNING;
				context.dispatchEvent( new WorkflowEvent( WorkflowEvent.RESUMED, _context ) );
			}
			//REMOVE: dispatchTaskEvent( WorkflowEvent.RESUMED, inTask );
		}

		/**
		 * @private
		 */
		INTERNAL function onSubtaskSuspended( inTask : IWorkflowTask ) : void
		{
			//TODO: this should be managed at workflow/context level
			if( root.context.status != TaskStatus.SUSPENDED )
			{
				context.status = TaskStatus.SUSPENDED;
				context.dispatchEvent( new WorkflowEvent( WorkflowEvent.SUSPENDED, _context ) );
			}
			//REMOVE: dispatchTaskEvent( WorkflowEvent.SUSPENDED, inTask );
		}

		/**
		 * @private
		 */
		override protected function onTimeout( inOriginalThread : int ) : void
		{
			if( currentThread != inOriginalThread )
				return;
			_exitStatus = new ExitStatus( ExitStatus.TIME_OUT );

			ENV.astoolkit_private::runningTask = this;
			LOGGER.debug( "Task {0} failed because a {1}s timeout occourred",
				description,
				Number( _timeout ) / 1000 );
			abort();
		}

		protected function prepareChildren() : void
		{
			for each( var element : IWorkflowElement in _children )
			{
				element.liveCycleDelegate = _childrenDelegate;
				element.currentIterator = _iterator;
				element.prepare();
			}
		}

		/**
		 * @private
		 *
		 * returns true if children were processed synchronously
		 */
		protected function processChildren() : Boolean
		{
			var w : ITaskLiveCycleWatcher;

			if( _status == TaskStatus.SUSPENDED )
			{
				_context.suspendableFunctions.addResumeCallBack( resumeProcessIteration );
				return false;
			}

			if( _status != TaskStatus.RUNNING )
				return false;

			if( !_elementsQueue.hasPendingElements() )
				return true;


			_context.variables.onGroupCheckingNextTask( this, _subPipelineData );
			var element : IWorkflowElement;

			while( _status != TaskStatus.ABORTED && _elementsQueue.hasNext() )
			{
				var task : IWorkflowTask;
				element = _elementsQueue.next();
				element.wakeup();

				if( element is IDeferrableProcess &&
					IDeferrableProcess( element ).isProcessDeferred() )
				{
					_elementsQueue.onElementProcessDeferred( element as IDeferrableProcess );
					IDeferrableProcess( element ).addDeferredProcessWatcher(
						onDeferredProcessResume );

					if( flow == Flow.SERIAL )
					{
						return false;
					}
					else
						continue;
				}

				if( element is IPipelineConsumer )
				{
					setSubtaskPipelineData( IPipelineConsumer( element ) );
						//REMOVE: dispatchTaskEvent( WorkflowEvent.DATA_SET, task );
				}

				if( element is ITaskProxy )
					task = ITaskProxy( element ).getTask();
				else if( element is IWorkflowTask )
					task = element as IWorkflowTask;
				else
					continue;


				if( !task || !task.enabled )
					continue;

				for each( w in _context.taskLiveCycleWatchers )
					w.onTaskPhase( task, TaskPhase.BEFORE_BEGIN );

				BindingUtility.touch( _document, "ENV", _context.variables );

				_executingTask = task;
				runSubTask( task );

				if( task.exitStatus &&
					task.exitStatus.interrupted &&
					( task.failurePolicy == FailurePolicy.CASCADE ||
					task.failurePolicy == FailurePolicy.ABORT ) )
					return false;

				if( _status != TaskStatus.RUNNING )
					return false;

				if( task.running && _flow == Flow.SERIAL )
				{
					return false;
				}
			}
			return true;
		}

		protected function processIteration( inResuming : Boolean = false ) : void
		{
			if( _status == TaskStatus.ABORTED )
				return;

			while( _status != TaskStatus.ABORTED &&
				( _iterator.hasNext() || inResuming ) )
			{
				if( !inResuming )
				{
					nextData();
					prepareChildren();
				}
				else
					inResuming = false;

				if( !processChildren() )
					return;
			}

			if( _status != TaskStatus.RUNNING )
				return;
			completeGroup();
		}

		protected function resumeProcessIteration() : void
		{
			processIteration( true );
		}

		protected function runSubTask( inTask : IWorkflowTask ) : void
		{
			var w : ITaskLiveCycleWatcher;

			try
			{
				inTask.begin();

				if( _status != TaskStatus.RUNNING ) //inTask could have invoked suspend()
					return;
			}
			catch( taskError : Error )
			{
				INTERNAL::onSubtaskFault(
					inTask,
					taskError.getStackTrace()
					);
				return;
			}
			_executingTask = null;

			for each( w in _context.taskLiveCycleWatchers )
				w.onTaskPhase( inTask, TaskPhase.AFTER_BEGIN );
		}

		protected function setSubtaskPipelineData( inElement : IPipelineConsumer ) : void
		{
			if( _subPipelineData == UNDEFINED )
			{
				if( _feed == Feed.PIPELINE ||
					( _feed == Feed.AUTO && _iterator == null ) || _iterate == Iterate.ONCE )
				{
					_subPipelineData = filteredInput;
				}
				else if( _feed == Feed.CURRENT_DATA ||
					( _feed == Feed.AUTO && _iterator != null ) )
				{
					_subPipelineData = _iterator.current();
				}
			}
			var taskData : Object = _subPipelineData;

			if( inElement is IWorkflowTask )
			{
				var task : IWorkflowTask = inElement as IWorkflowTask;

				//TODO: consider whether to remove this feature for the sake of removing
				//		IEventDispatcher contract from tasks
				if( IEventDispatcher( task ).hasEventListener( WorkflowEvent.TRANSFORM_INPUT ) )
				{
					var transformEvent : WorkflowEvent =
						new WorkflowEvent(
						WorkflowEvent.TRANSFORM_INPUT,
						context,
						task,
						taskData );

					IEventDispatcher( task ).dispatchEvent( transformEvent );
					taskData = transformEvent.data;
				}

				if( task.output == UNDEFINED )
				{
					if( task.inlet is String )
					{
						try
						{
							if( Object( inElement ).hasOwnProperty( task.inlet ) )
							{
								if( inElement[ task.inlet ] is Function )
								{
									var f : Function = inElement[ task.inlet ] as Function;
									f.apply( task, [ taskData ] );
								}
								else
									inElement[ task.inlet ] = taskData;
							}
						}
						catch( e : Error )
						{
							throw new Error( "Error while trying to set pipeline data to  " +
								"task's property/function '" + task.inlet + "'\n\n" +
								e.getStackTrace() );
						}
					}
					else if( task.inlet is IPropertiesMapper )
					{
						var mapper : IPropertiesMapper = task.inlet as IPropertiesMapper;

						try
						{
							mapper.map( taskData, inElement );
						}
						catch( e : Error )
						{
							throw new Error( "Error while trying to map pipeline " +
								"data properties to task properties with IPropertiesMapper.\n\n" +
								e.getStackTrace() );
						}
					}
				}
				inElement.input = taskData;
			}
		}

		private function onDeferredProcessResume( inProcess : IDeferrableProcess ) : void
		{
			_elementsQueue.onDeferredElementResume( inProcess );
			resumeProcessIteration();
		}

		private function setupIterator() : void
		{
			if( _iterator )
				return;

			if( _iterate == Iterate.DATA )
			{

				if( _iterator == null )
				{
					if( _dataProvider )
						_iterator = _context.resolveIterator( _dataProvider );
					else
						_iterator = _context.resolveIterator( filteredInput );
				}

			}
			else
			{
				if( _iterate == Iterate.LOOP )
				{
					_iterator = _context.resolveIterator(
						Range.create( uint.MIN_VALUE, uint.MAX_VALUE ),
						_iteratorConfig );
					_iterator.cycle = true;
				}
				else if( _iterate == Iterate.ONCE )
					_iterator = _context.resolveIterator( Range.create( 0, 1 ) );
			}
		}
	}
}
include "includes/DoChildTaskWatcherInclude.as";

