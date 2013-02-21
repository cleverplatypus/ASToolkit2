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

	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;

	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.logging.ILogger;
	import mx.utils.StringUtil;

	import org.astoolkit.commons.databinding.BindingUtility;
	import org.astoolkit.commons.io.transform.api.IIODataTransformer;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	import org.astoolkit.commons.mapping.api.IPropertiesMapper;
	import org.astoolkit.commons.process.api.IDeferrableProcess;
	import org.astoolkit.commons.reflection.Field;
	import org.astoolkit.commons.reflection.PropertyDataBuilderInfo;
	import org.astoolkit.commons.reflection.Type;
	import org.astoolkit.commons.utils.getLogger;
	import org.astoolkit.workflow.annotation.InjectPipeline;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.constant.*;
	import org.astoolkit.workflow.internals.ContextVariablesProvider;

	[Exclude( name = "ENV", kind = "property" )]
	[Exclude( name = "delegate", kind = "property" )]
	[Exclude( name = "currentProgress", kind = "property" )]
	[Exclude( name = "context", kind = "property" )]
	[Exclude( name = "parent", kind = "property" )]
	/**
	 * dispatched only once, when the root workflow begins.
	 *
	 * @eventType org.astoolkit.workflow.WorkflowEvent
	*/
	[Bindable]
	/**
	 * Base implementation of <code>IWorkflowTask</code>; Every task implementation must extend this class.
	 *
	 * <p>Functionality for input filtering, property overriding,
	 * completion and so on are provided here.</p>
	 * <p>Typically, a subclass overrides the <code>begin()</code>method
	 * and calls <code>complete( ... )</code> or <code>fail( ... )</code>
	 * either from within <code>begin()</code>, if the task completes synchronously
	 * or inside some other asynchronously called method, e.g. an event handler.</p>
	 * <p><code>BaseTask</code> defines the special <code><b>$</b></code> variable
	 * which holds a reference to the context's variables dictionary.
	 * Tasks' event handlers and bindings can safely use this
	 * property to access pre-defined or custom context variables</p>
	 *
	 * @see org.astoolkit.workflow.internals.ContextVariablesProvider
	 *
	 * @example Accessing the current pipeline data using the <code>$</code> property.
	 * 			<p>In this example we're executing an hypothetical
	 * 			<code>SendCatalogViaEmail</code> task passing the pipeline data's <code>email</code>
	 * 			property to the <code>recipient</code> parameter (assuming that the current
	 * 			pipeline data is an object of type <code>Company</code>).</p>
	 * <listing version="3.0">
	 * &lt;pr:SendCatalogViaEmail
	 * 		recipient="{ Company( ENV.$data ).email }"
	 * 		/&gt;
	 * </listing>
	 */
	public class BaseTask extends BaseElement implements IWorkflowTask
	{
		/**
		 * @private
		 */
		private static const LOGGER : ILogger = getLogger( BaseElement );

		/**
		 * @private
		 *
		 * When set to true, execution of the task is deferred. This can happen
		 * during the wakeup phase, when a property needs to be processed asynchronously
		 * before proceeding.
		 */
		private var _configDeferred : Boolean;

		/**
		 * @private
		 *
		 * a list of objects to be notified when this task is ready to be executed after
		 * going on hold for async configuration
		 */
		private var _deferredExecutionWatchers : Vector.<Function>;

		/**
		 * @private
		 *
		 * true if this task has a delay > 0 and such delay has elapsed
		 */
		private var _delayHasElapsed : Boolean;

		/**
		 * @private
		 */
		private var _delayTimer : Timer;

		/**
		 * @private
		 */
		private var _root : ITasksGroup;

		/**
		 * @private
		 */
		internal var _pipelineData : * = UNDEFINED;

		/**
		 * @private
		 */
		protected var __status : String;

		/**
		 * @private
		 */
		protected var _currentProgress : Number = -1;

		protected var _dataTransformerRegistry : IIODataTransformerRegistry

		/**
		 * @private
		 */
		protected var _delay : int;

		/**
		 * @private
		 *
		 * The task's exit status.
		 */
		protected var _exitStatus : ExitStatus;

		/**
		 * @private
		 */
		protected var _failureMessage : String;

		/**
		 * @private
		 */
		protected var _failurePolicy : String = FailurePolicy.CASCADE;

		protected var _forceAsync : Boolean;

		/**
		 * @private
		 */
		protected var _ignoreOutput : Boolean;

		/**
		 * @private
		 */
		protected var _inlet : Object;

		/**
		 * Holds the unfiltered input data passed to the pipeline.
		 */
		protected var _inputData : * = UNDEFINED;

		/**
		 * @private
		 */
		protected var _inputFilter : Object;

		/**
		 * @private
		 */
		protected var _invalidPipelinePolicy : String = InvalidPipelinePolicy.IGNORE;

		/**
		 * @private
		 */
		protected var _outlet : Object = PIPELINE_OUTLET;

		/**
		 * @private
		 */
		protected var _outputFilter : Object;

		/**
		 * @private
		 */
		protected var _outputKind : String = "auto";

		/**
		 * @private
		 */
		protected function get _status() : String
		{
			return __status;
		}

		/**
		 * @private
		 */
		protected function set _status( inStatus : String ) : void
		{
			var oldValue : String = __status;
			__status = inStatus;
			dispatchEvent(
				new PropertyChangeEvent(
				"status_change",
				false,
				false,
				PropertyChangeEventKind.UPDATE,
				"status",
				oldValue,
				__status,
				this ) );
		}

		/**
		 * @private
		 */
		protected var _taskCompleted : Boolean;

		/**
		 * @private
		 */
		protected var _taskParametersMapping : Object;

		/**
		 * @private
		 */
		protected var _timeout : int = -1;

		/**
		 * A reference to the context's variables dictionary.
		 * <p>Tasks' event handlers and bindings can safely use this
		 * property to access pre-defined or custom context variables</p>
		 *
		 * @example accessing the current pipeline data.
		 * 			<p>In this example we're executing an hypothetical
		 * 			<code>SendCatalogViaEmail</code> task passing the pipeline data's <code>email</code>
		 * 			property to the <code>recipient</code> parameter (assuming that the current
		 * 			pipeline data is an object of type <code>Company</code>).
		 * <listing version="3.0">
		 * &lt;pr:SendCatalogViaEmail
		 * 		recipient="{ Company( ENV.$data ).email }"
		 * 		/&gt;
		 * </listing>
		 */
		public function get ENV() : ContextVariablesProvider
		{
			return context ? context.variables : null;
		}

		public function set ENV( inValue : * ) : void
		{
		/*
			empty setter definition necessary to avoid the read-only
			bindable property warning
		*/
		}

		override public function set context( inContext : IWorkflowContext ) : void
		{
			super.context = inContext;

			if( _context )
				for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
					w.onTaskPhase( this, TaskPhase.CONTEXT_BOND, _context );

		}

		/**
		 * @inheritDoc
		 */
		public function get currentProgress() : Number
		{
			return _currentProgress;
		}

		public function set currentProgress( inProgress : Number ) : void
		{
			_currentProgress = inProgress;
		}

		/**
		 * an integer that identifies a task's cycle of execution.
		 * <p>Used to keep track of resources allocated for each cycle.
		 * Event handlers, tipically allocated in the <code>begin()</code> method,
		 * for example, must be unregistered when the task completes or fails to
		 * prevent async calls to such handlers from disrupting the workflow.</p>
		 */
		public function get currentThread() : uint
		{
			return _thread;
		}

		public function set dataTransformerRegistry( inRegistry : IIODataTransformerRegistry ) : void
		{
			_dataTransformerRegistry = inRegistry;
		}

		/**
		 * @inheritDoc
		 */
		public function get delay() : int
		{
			return _delay;
		}

		public function set delay( inDelay : int ) : void
		{
			_delay = inDelay;

			if( _delay > 0 && !_delayTimer )
				_delayTimer = new Timer( _delay, 1 );

			if( _delayTimer )
				_delayTimer.delay = _delay;
		}

		public function get exitStatus() : ExitStatus
		{
			return _exitStatus;
		}

		/**
		 * @example Custom failure status.
		 * 			<p>In the following example, our task is failing using a custom
		 * 			networkUnavailable exit status code</p>
		 *
		 * <listing version="3.0">
		 * exitStatus = new ExitStatus( "networkUnavailable", "Task failed because the network is unavailable", null, true );
		 * fail();
		 * </listing>
		 *
		 * @see org.astoolkit.workflow.core.ExitStatus
		 * @inheritDoc
		*/

		public function set exitStatus( inStatus : ExitStatus ) : void
		{
			_exitStatus = inStatus;
		}

		public function get failureMessage() : String
		{
			return _failureMessage;
		}

		/**
		 * @inheritDoc
		 */
		public function set failureMessage( inValue : String ) : void
		{
			_failureMessage = inValue;
		}

		[Inspectable(
			defaultValue = "cascade",
			enumeration = "cascade,abort,suspend,ignore,continue,log-debug,log-info,log-warn,log-error" )]
		/**
		 * @inheritDoc
		 */
		public function get failurePolicy() : String
		{
			return _failurePolicy;
		}

		override public function set failurePolicy( inPolicy : String ) : void
		{
			_failurePolicy = inPolicy;
		}

		/**
		 *
		 * returns the pipeline data used by this task.<br><br>
		 * If a filter has been defined, filteredPipelineData will return
		 * the filtered data. Otherwise it will return the raw data.
		 */
		public function get filteredInput() : Object
		{
			if( _inputFilter )
			{
				var filter : IIODataTransformer =
					_inputFilter is IIODataTransformer ?
					_inputFilter as IIODataTransformer :
					_dataTransformerRegistry.getTransformer( _inputData, _inputFilter );

				if( !filter )
				{
					var filterData : String = _inputFilter is String ?
						"\"" + _inputFilter + "\"" : getQualifiedClassName( _inputFilter );
					LOGGER.error( "Cannot find a suitable filter instance " +
						"in task {0} for data {1} and filter {2}",
						description,
						getQualifiedClassName( _inputData ),
						filterData );
					throw new Error( "Error filtering input data for task \"" + description + "\"" );
				}
				var data : Object = _inputData;

				while( filter )
				{
					data = filter.transform(
						data,
						_inputFilter is IIODataTransformer ? null : _inputFilter,
						this );
					filter = filter.next;
				}
				return data;
			}
			else
				return _inputData;
		}

		/**
		 * @private
		 */
		public function get forceAsync() : Boolean
		{
			return _forceAsync;
		}

		/**
		 * @private
		 */
		public function set forceAsync( inValue : Boolean ) : void
		{
			_forceAsync = inValue;
		}

		public function get ignoreOutput() : Boolean
		{
			return _ignoreOutput;
		}

		public function set ignoreOutput( inIgnoreOutput : Boolean ) : void
		{
			_ignoreOutput = inIgnoreOutput;
		}

		public function get inlet() : Object
		{
			return _inlet;
		}

		/**
		 * an optional object used to map data to this task's properties.
		 * <p>If set to a String, the parent workflow will try to inject
		 * the pipeline data using the property/function name provided.
		 * the framework expects inlet functions to receive one argument
		 * of the appropriate type</p>
		 *
		 * <p>If an <code>IPropertiesMapper</code> is provided, the task will try to
		 * map its properties to the pipeline data's properties.</p>
		 *
		 * <p><code>{ administratorUser : "user" }</code> will map the task's
		 * <code>user</code> property to the pipeline's data object's
		 * <code>administratorUser</code> property.</p>
		 * Notice that the task's taskInput is set anyway,
		 * even with inlet specified.
		 */
		public function set inlet( inInlet : Object ) : void
		{
			_inlet = inInlet;
		}

		public function set input( inData : * ) : void
		{
			_pipelineData = _inputData = inData;
		}

		public function get inputFilter() : Object
		{
			return _inputFilter;
		}

		/**
		 * a filter for this task's pipeline data.<br><br>
		 * It can be either a <code>String</code> representing
		 * the properties chain to drill into the taskInput,
		 * a reference to a function receiving
		 * the original pipeline data as unique parameter
		 * and returning the filtered data or  a reference to
		 * a class or instance of an implementation of IIOFilter<br><br>
		 *
		 * @example Passing a function reference:<br>
		 * <listing version="3.0">
		 * private function userFriendsFilter( inUser : User ) : ArrayCollection
		 * {
		 * 		return inUser.getAllFriends();
		 * }
		 * </listing>
		 * <listing version="3.0">
		 * &lt;PrintOutUserFriendsTask
		 * 		inputFilter="{ userFriendsFilter }"
		 * 		/&gt;
		 * </listing>
		 * <br><br>
		 * @example Passing a property chain<br>
		 * <listing>
		 * &lt;PrintOutUserPostCodeTask
		 * 		inputFilter="address.postcode"
		 * 		/&gt;
		 * </listing>
		 *
		 * @example Passing an IIOFilter instance
		 * <listing version="3.0">
		 * private var _myUserPostCodeFilter : UserPostCodeFilter;
		 * </listing>
		 * or, to avoid script sections in workflows
		 * <listing version="3.0">
		 * &lt;fx:Declarations&gt;
		 * 	&lt;filters:UserPostCodeFilter
		 * 		id="_myUserPostCodeFilter"
		 * 		myParam="bla"/&gt;
		 * &lt;/fx:Declarations&gt;
		 * * </listing>
		 * <listing version="3.0">
		 * &lt;PrintOutUserPostCodeTask
		 * 		inputFilter="{ _myUserPostCodeFilter }"
		 * 		/&gt;
		 * </listing>
		 *
		 * @example Passing an IIOFilter class
		 * <listing version="3.0">
		 * &lt;PrintOutUserPostCodeTask
		 * 		inputFilter="{ com.acmescript.filters.UserPostCodeFilter }"
		 * 		/&gt;
		 * </listing>
		 * Notice that, unless you need to configure the filter at runtime
		 * passing the filter's class is preferable. <code>BaseTask</code>
		 * will cache any declared filters for reuse, therefore filters
		 * must be stateless.
		 */
		public function set inputFilter( inValue : Object ) : void
		{
			_inputFilter = inValue;
		}

		public function get invalidPipelinePolicy() : String
		{
			return _invalidPipelinePolicy;
		}

		/**
		 * determines what to do when the parent's pipeline data
		 * is <code>EMPTY_PIPELINE</code> <u>before</u> executing this task.<br>
		 * <code>ignore</code> (default): execute the task.<br>
		 * <code>fail</code>: call fail()<br>
		 * <code>skip</code>: ignore this task and go ahead<br>
		 */
		[Inspectable( defaultValue = "ignore", enumeration = "ignore,skip,fail" )]
		public function set invalidPipelinePolicy( inValue : String ) : void
		{
			_invalidPipelinePolicy = inValue;
		}

		public function get outlet() : Object
		{
			return _outlet;
		}

		[AutoAssign( match = "org.astoolkit.commons.mapping.api.IPropertiesMapper" )]
		[AutoAssign( match = "org.astoolkit.commons.mapping.api.IPropertiesMapperFactory" )]
		/**
		 * the destination of the task's output data.
		 * <p>Possible values:
		 * <ul>
		 * <li><code>$variableName</code>: saves the output data to a context variable</li>
		 * <li><code>org.astoolkit.workflow.constant.PIPELINE_OUTLET</code> (default): the output will be passed to the parent's pipeline.</li>
		 * <li>an instance of <a href="../../commons/mapping/IPropertiesMapper.html"><code>IPropertiesMapper</code></a></li>
		 * </ul>
		 * When using an instance of
		 * </p>
		 * @example Using a property mapper as <code>outlet</code>.
		 * 			<p>In this example we have an async task that shows a login
		 * 			panel and waits for the user to enter his/her credentials.</p>
		 * 			<p>Its output will be some kind of value object (e.g. CredentialsVO) containing
		 * 			the user provided information as <code>email</code> and <code>password</code>
		 * 			properties.</p>
		 * 			<p>We use the <a href="../../commons/mapping/MapTo.html"><code>MapTo</code></a> utility class to create an instance of
		 * 			<code>TryLoginMessage</code> mapping <code>CredentialsVO.email</code> to
		 * 			<code>TryLoginMessage.username</code> and <code>CredentialsVO.password</code> to
		 * 			<code>TryLoginMessage.password</code>.</p>
		 * 			<p>Since we're passing <code>TryLoginMessage</code> class,
		 * 			the factored object will be put in the output pipeline.</p>
		 * <listing version="3.0">
		 * &lt;view:GetLoginCredentials
		 * 		outlet="{ MapTo.object( TryLoginMessage, { username : 'email', password : 'password' } "
		 * 		/&gt;
		 * &lt;msg:SendMessage /&gt;
		 * </listing>
		 *
		 * @see org.astoolkit.commons.mapping.IPropertiesMapper
		 * @see org.astoolkit.commons.mapping.MapTo
		 */
		public function set outlet( inOutlet : Object ) : void
		{
			_outlet = inOutlet;
		}

		/**
		 * after <code>complete()</code> will return this task's pipelineData
		 */
		public function get output() : *
		{
			return _pipelineData;
		}

		public function get outputFilter() : Object
		{
			return _outputFilter;
		}

		public function set outputFilter( inValue : Object ) : void
		{
			_outputFilter = inValue;
		}

		[Inspectable( enumeration = "auto", defaultValue = "auto" )]
		public function set outputKind( inValue : String ) : void
		{
			_outputKind = inValue;
		}

		/**
		 * @private
		 */
		public function get root() : ITasksGroup
		{
			if( _root )
				return _root;
			var out : IWorkflowElement = this;

			while( out.parent != null )
			{
				out = out.parent;
			}
			_root = out as ITasksGroup;
			return _root;
		}

		public function get running() : Boolean
		{
			return _status == TaskStatus.RUNNING && !_taskCompleted;
		}

		public function get status() : String
		{
			return _status;
		}

		public function set taskParametersMapping( inValue : Object ) : void
		{
			_taskParametersMapping = inValue;
		}

		/**
		 * an optional timeout expressed in milliseconds after which
		 * if the task hasn't completed it will abort with
		 * <code>exitStatus.code = ExitStatus.TIME_OUT</code>.
		 */
		public function set timeout( inMillisecs : int ) : void
		{
			_timeout = inMillisecs;
		}

		/**
		 * @private
		 */
		public function BaseTask()
		{
			super();
			_outlet = PIPELINE_OUTLET;
			_status = TaskStatus.STOPPED;
		}

		/**
		 * @inheritDoc
		 */
		public function abort() : void
		{
			LOGGER.debug( "abort() '{0}' ({1})", description, getQualifiedClassName( this ) );
			_status = TaskStatus.ABORTED;

			if( !_exitStatus )
			{
				exitStatus = new ExitStatus( ExitStatus.ABORTED );

				for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
					w.onTaskPhase( this, TaskPhase.EXIT_STATUS, _exitStatus );
			}
			_thread++;

			//REMOVE: dispatchTaskEvent( WorkflowEvent.ABORTED, this );

			if( _delegate )
				_delegate.onTaskPhase( this, TaskPhase.ABORTED );

			if( !_parent )
				cleanUp();
		}

		public function addDeferredProcessWatcher( inWatcher : Function ) : void
		{
			if( !_deferredExecutionWatchers )
				_deferredExecutionWatchers = new Vector.<Function>();
			_deferredExecutionWatchers.push( inWatcher );
		}

		public function begin() : void
		{
			if( _timeout > 0 )
			{
				var threadNo : int = currentThread;
				setTimeout( onTimeout, _timeout, threadNo );
			}
			_taskCompleted = false;

			if( !_context || ( !( this is ITasksGroup ) && !_parent ) )
			{
				throw new Error( "This task is not initialized properly." +
					"Tasks are not meant to run stand-alone." +
					"Wrap it with an IWorkflow" );
			}

			if( _status == TaskStatus.RUNNING )
				throw new Error( "begin() called while task already running: " + getQualifiedClassName( this ) );
			LOGGER.debug( "begin() '{0}' ({1})", description, getQualifiedClassName( this ) );

			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskPhase( this, TaskPhase.BEGUN );
			_context.addEventListener( WorkflowEvent.SUSPENDED, onContextSuspended );
			_context.addEventListener( WorkflowEvent.RESUMED, onContextResumed );
			_context.runningTask = this;
			_status = TaskStatus.RUNNING;

			if( suspendBinding && _document != null )
				BindingUtility.enableAllBindings( _document, this );
			injectPipeline();

			if( _taskParametersMapping )
			{
				if( _taskParametersMapping is IPropertiesMapper )
					IPropertiesMapper( _taskParametersMapping ).map( filteredInput, this );
				else
					ENV.mapTo.object( this, _taskParametersMapping ).map( filteredInput, this );
			}

			if( _delegate )
				_delegate.onTaskPhase( this, TaskPhase.BEGUN );
		}

		override public function cleanUp() : void
		{
			_status = TaskStatus.STOPPED;

			_context.removeEventListener( WorkflowEvent.SUSPENDED, onContextSuspended );
			_context.removeEventListener( WorkflowEvent.RESUMED, onContextResumed );


		}

		override public function releaseContext() : void
		{
			var c : IWorkflowContext = _context;
			super.releaseContext();

			for each( var w : ITaskLiveCycleWatcher in c.taskLiveCycleWatchers )
				w.onTaskPhase( this, TaskPhase.CONTEXT_UNBOND, c );

		}

		/**
		* @inheritDoc
		*/
		override public function initialize() : void
		{
			super.initialize();

			if( _status != TaskStatus.STOPPED )
				return;

			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskPhase( this, TaskPhase.INITIALISED );

			if( _parent )
				_status = TaskStatus.IDLE;

			if( _delegate )
				_delegate.onTaskPhase( this, TaskPhase.INITIALISED );

			if( _document == null )
				_document = this;
		}

		public function isProcessDeferred() : Boolean
		{
			return ( _delay > 0 && !_delayHasElapsed ) || _configDeferred;
		}

		/**
		 * @inheritDoc
		 */
		override public function prepare() : void
		{
			if( parent )
			{
				IEventDispatcher( parent ).addEventListener(
					"status_change",
					onParentStatusChange );
				_pipelineData = UNDEFINED;
				_status = TaskStatus.IDLE;
			}
			_delayHasElapsed = false;
			_exitStatus = null;

			if( _delegate )
				_delegate.onTaskPhase( this, TaskPhase.PREPARED );
		}

		/**
		 * @inheritDoc
		 */
		public function resume() : void
		{
			if( _status != TaskStatus.RUNNING )
			{
				_status = TaskStatus.RUNNING;

				if( _delegate )
					_delegate.onTaskPhase( this, TaskPhase.RESUMED );
				_context.suspendableFunctions.invokeResumeCallBacks();
			}
		}

		/**
		 * @inheritDoc
		 */
		public function suspend() : void
		{
			if( _status != TaskStatus.SUSPENDED )
			{
				_status = TaskStatus.SUSPENDED;

				if( _delegate )
					_delegate.onTaskPhase( this, TaskPhase.SUSPENDED );
			}
		}

		/**
		 * @private
		 */
		public function toString() : String
		{
			return getQualifiedClassName( this );
		}

		override public function wakeup() : void
		{
			super.wakeup();

			if( _propertiesDataProviderInfo )
			{
				var value : *;

				for each( var prop : PropertyDataBuilderInfo in _propertiesDataProviderInfo )
				{
					value = prop.dataProvider.getData();

					if( value === undefined )
					{
						if( prop.dataProvider is IDeferrableProcess &&
							IDeferrableProcess( prop.dataProvider ).isProcessDeferred() )
						{
							_configDeferred = true;
							IDeferrableProcess( prop.dataProvider )
								.addDeferredProcessWatcher( onDeferredConfigPropertyComplete );
							return;
						}
					}
					else
					{
						this[ prop.name ] = value;
					}

				}
			}

			if( _delay > 0 && !_delayHasElapsed )
			{
				_delayTimer.addEventListener(
					TimerEvent.TIMER,
					threadSafe( onDelayTimeout ) );
				_delayTimer.reset();
				_delayTimer.start();
			}
		}

		/**
		 * @private
		 */
		protected function _deferredComplete( inThread : uint ) : void
		{
			if( inThread != _thread )
				return;

			if( !exitStatus )
			{
				exitStatus = new ExitStatus( ExitStatus.COMPLETE, null, _pipelineData );

				for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
					w.onTaskPhase( this, TaskPhase.EXIT_STATUS, _exitStatus );
			}
			LOGGER.debug(
				"Task '{0}' completed", description );

			if( suspendBinding && _document != null )
				BindingUtility.disableAllBindings( _document, this );

			if( _status == TaskStatus.SUSPENDED )
			{
				_context.suspendableFunctions.addResumeCallBack(
					function() : void
					{
						_deferredComplete( _thread );
					} );
				return;
			}
			_context.runningTask = null;
			_thread++;
			_status = TaskStatus.IDLE;

			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskPhase( this, TaskPhase.COMPLETED );

			if( _delegate )
				_delegate.onTaskPhase( this, TaskPhase.COMPLETED );
		}

		/**
		 * @private
		 */
		protected function _deferredFail( inMessage : String, inThread : uint ) : void
		{
			if( inThread != _thread )
				return;

			if( failurePolicy == FailurePolicy.CASCADE ||
				failurePolicy == FailurePolicy.ABORT )
				LOGGER.error(
					"Task {0}:\"{1}\" failed. Reason: {2} \nData:\n{3}",
					description,
					getQualifiedClassName( this ),
					inMessage,
					_inputData );
			else if( failurePolicy.toLowerCase().match( /^log\-/ ) )
			{
				LOGGER[ failurePolicy.replace( /^log\-/, "" ) ](
					"Task " + description + " failed with message:\n" + inMessage );
			}
			else
			{
				LOGGER.debug( inMessage );
			}

			if( _status == TaskStatus.SUSPENDED )
			{
				_context.suspendableFunctions.addResumeCallBack(
					function() : void
					{
						_deferredFail( inMessage, inThread );
					} );
				return;
			}
			_thread++
			_status = TaskStatus.IDLE;

			if( _delegate )
				_delegate.onTaskPhase( this, TaskPhase.FAILED, inMessage );
		}

		/**
		 * @private
		 */
		protected function complete( inOutputData : * = undefined ) : void
		{
			if( _status != TaskStatus.RUNNING )
				return;

			for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
				w.onTaskPhase( this, TaskPhase.OUTPUT, inOutputData );

			if( inOutputData != UNDEFINED && inOutputData !== undefined )
				_pipelineData = inOutputData;
			_taskCompleted = true;
			_deferredComplete( _thread );
		}

		/**
		 * call this method if a failure occurs during a task's execution.
		 *
		 * @param inMessage the text to be logged or passed to a
		 * 					fail event. Placeholders {<em>n</em>} can be used
		 * 					to perform text substitution
		 * @param inRest optional parameters for text substitution
		 *
		 * @example Calling fail()
		 * <listing version="3.0">
		 * try
		 * {
		 *    ...
		 * }
		 * catch( e : Error )
		 * {
		 *     fail( "Task failed with code {0}", e.code );
		 *     return;
		 * }
		 * </listing>
		 */
		protected function fail( inMessage : String, ... inRest ) : void
		{
			if( _status == TaskStatus.ABORTED )
				return;

			if( !exitStatus )
			{
				exitStatus = new ExitStatus( ExitStatus.FAILED, inMessage )

				for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
					w.onTaskPhase( this, TaskPhase.EXIT_STATUS, _exitStatus );
			}
			var args : Array = [ inMessage ].concat( inRest );
			var message : String = StringUtil.substitute.apply( null, args );
			_deferredFail( message, _thread );
		}

		protected function injectPipeline() : void
		{
			//TODO: move this away from here
			var ci : Type = Type.forType( this );
			var fields : Vector.<Field> = ci.getFieldsWithAnnotation( InjectPipeline );
			var data : Object = filteredInput;
			var defaultPropSet : Boolean;
			var annotation : InjectPipeline;

			for each( var field : Field in fields )
			{
				if( !propertyWasSetExplicitly( field.name ) )
				{
					annotation = field.getAnnotationsOfType( InjectPipeline )[ 0 ] as InjectPipeline;

					if( !defaultPropSet && annotation.filterText == null &&
						( field.type == null || data is field.type ) )
					{
						this[ field.name ] = data;
						defaultPropSet = true;
					}
					else if( annotation.filterText != null )
					{
						this[ field.name ] =
							_context
							.config
							.dataTransformerRegistry
							.getTransformer(
							data,
							annotation.filterText )
							.transform(
							data,
							annotation.filterText,
							this );
					}
				}
			}
		}

		protected function notifyDeferredProcessWatchers() : void
		{
			var watchers : Vector.<Function> = _deferredExecutionWatchers.concat();
			_deferredExecutionWatchers.length = 0;

			while( watchers.length > 0 )
				( watchers.pop() as Function )( this );
		}

		/**
		 * @private
		 */
		protected function onContextResumed( inEvent : WorkflowEvent ) : void
		{
			if( status == TaskStatus.SUSPENDED )
			{
				resume();
			}
		}

		/**
		 * @private
		 */
		protected function onContextSuspended( inEvent : WorkflowEvent ) : void
		{
			if( _status == TaskStatus.RUNNING )
			{
				suspend();
			}
		}

		protected function onDeferredConfigPropertyComplete( ... rest ) : void
		{
			_configDeferred = false;
			notifyDeferredProcessWatchers();
		}

		/**
		 * @private
		 */
		protected function onParentStatusChange( inEvent : PropertyChangeEvent ) : void
		{
			if( inEvent.newValue == TaskStatus.ABORTED )
			{
				_status = TaskStatus.ABORTED;
				_thread++;
			}
		}

		/**
		 * @private
		 */
		protected function onTimeout( inOriginalThread : int ) : void
		{
			if( currentThread != inOriginalThread )
				return;

			if( _exitStatus )
			{
				exitStatus = new ExitStatus( ExitStatus.TIME_OUT );

				for each( var w : ITaskLiveCycleWatcher in _context.taskLiveCycleWatchers )
					w.onTaskPhase( this, TaskPhase.EXIT_STATUS, _exitStatus );
			}
			fail( "Task {0} failed because a {1}s timeout occourred",
				description,
				Number( _timeout ) / 1000 );
		}

		/**
		 * @private
		 */
		protected function setProgress( inValue : Number ) : void
		{
			var oldVal : Number = _currentProgress;
			_currentProgress = inValue;

			if( _currentProgress >= 0 && _currentProgress <= 1 )
			{
				if( _delegate )
					_delegate.onTaskPhase( this, TaskPhase.PROGRESS );
				/*				dispatchEvent(
									new PropertyChangeEvent(
									PropertyChangeEvent.PROPERTY_CHANGE,
									false,
									true,
									PropertyChangeEventKind.UPDATE,
									"progress",
									oldVal,
									_currentProgress,
									this ) );
				*/
			}

		}

		/**
		 * returns a function wrapper that prevents functions called by async
		 * processes from being invoked if the task is aborted before
		 * the async process has completed (e.g. for a <a href="./BaseTask.html#timeout"><code>timeout</code></a>).
		 *
		 * @example Safe event handler
		 * <listing version="3.0">
		 * override public function begin() : void
		 * {
		 *     //...
		 *
		 *     httpService.addEventListener( FaultEvent.FAULT, threadSafe( onHttpServiceFault ) );
		 * }
		 *
		 * protected function onHttpServiceFault( inEvent : FaultEvent ) : void
		 * {
		 *     fail( "Service returned a fault" );
		 * }
		 * </listing>
		 *
		 */
		protected function threadSafe( inHandler : Function ) : Function
		{
			return _context.suspendableFunctions.getThreadSafeFunction( this, inHandler );
		}

		private function onDelayTimeout( inEvent : TimerEvent ) : void
		{
			_delayHasElapsed = true;

			if( !isProcessDeferred() )
				notifyDeferredProcessWatchers();
		}
	}
}

