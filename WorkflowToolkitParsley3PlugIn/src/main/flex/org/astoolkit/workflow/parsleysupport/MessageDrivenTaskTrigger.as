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
package org.astoolkit.workflow.parsleysupport
{

	import flash.events.IEventDispatcher;
	import flash.utils.setTimeout;

	import mx.core.IMXMLObject;
	import mx.core.mx_internal;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.utils.UIDUtil;

	import org.astoolkit.commons.factory.*;
	import org.astoolkit.commons.factory.api.IPooledFactory;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerClient;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.constant.TaskStatus;
	import org.astoolkit.workflow.core.ExitStatus;
	import org.astoolkit.workflow.core.WorkflowEvent;
	import org.spicefactory.lib.reflect.ClassInfo;
	import org.spicefactory.parsley.comobserver.receiver.DefaultCommandObserver;
	import org.spicefactory.parsley.core.command.CommandObserverProcessor;
	import org.spicefactory.parsley.core.context.Context;
	import org.spicefactory.parsley.core.context.provider.Provider;
	import org.spicefactory.parsley.core.messaging.MessageProcessor;
	import org.spicefactory.parsley.core.messaging.MessageReceiverKind;
	import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
	import org.spicefactory.parsley.core.registry.ObjectDefinition;
	import org.spicefactory.parsley.core.scope.ScopeName;
	import org.spicefactory.parsley.messaging.receiver.DefaultMessageHandler;
	import org.spicefactory.parsley.messaging.receiver.MessageReceiverInfo;

	[DefaultProperty( "workflow" )]
	/**
	 * A wrapper node for Parsley context to declare workflows
	 * that are triggered by messages.<br><br>
	 * The workflow to be executed can be set as a reference to an IWorkflow
	 * in the <code>workflow</code> property or setting taskRefId to a context's object id.<br><br>
	 * If the referenced context object is defined as DynamicObject,
	 * a new instance is created or an instance from the pool is retrieved everytime the trigger message is received.
	 * This is useful when workflows need to be invoked repetedly as
	 * singleton objects would fail if run() is called when a
	 * workflow is still executing.
	 */
	public class MessageDrivenTaskTrigger implements IMXMLObject
	{

		private var _commandsCache : Object = {};

		private var _factory : IPooledFactory;

		private var _id : String;

		private var _parsleyContext : Context;

		[Inspectable( enumeration="messageHandler,command,resultOverride,managed" )]
		public var behaviour : String = "messageHandler";

		[Inject]
		public function set context( inContext : Context ) : void
		{
			_parsleyContext = inContext;
		}

		//TODO: only allow workflow reference by class or refId
		public var enabled : Boolean = true;

		public var inputFilter : Object;

		public var messageType : Class;

		public var scope : String  = ScopeName.GLOBAL;

		public var selector : * = undefined;

		public var taskRefId : String;

		public var workflow : IWorkflow;

		public var workflowType : Class;

		public function commandHandler( inMessage : Object ) : AsyncToken
		{
			if( !enabled )
				return null;
			var aWorkflow : IWorkflow = resolveWorkflow();
			var token : AsyncToken = new AsyncToken();
			_commandsCache[ UIDUtil.getUID( aWorkflow ) ] = token;
			setTimeout( aWorkflow.run, 1, inMessage );
			return token;
		}

		public function handler( inMessage : Object ) : void
		{
			if( !enabled )
				return;
			resolveWorkflow().run( inMessage );
		}

		[Init]
		public function init() : void
		{
			_factory = new PooledFactory();
			_factory.backupProperties = [ "inputFilter" ];
			var parsleyContextFactory : ParsleyContextObjectFactory = 
				new ParsleyContextObjectFactory();
			parsleyContextFactory.context = _parsleyContext;
			parsleyContextFactory.singletonInstance = false;
			_factory.delegate = new DynamicPoolFactoryDelegate( parsleyContextFactory );
			registerMessageListener();
		}

		public function initialized( inDocument : Object, inId : String ) : void
		{
			_id = inId;
		}

		public function managedHandler( 
			inMessage : Object, 
			inProcessor : MessageProcessor ) : void
		{
			if( !enabled )
				return;
			var workflow : IWorkflow = resolveWorkflow();
			var outResult : * = workflow.run( inMessage );

			if( workflow.context.status != TaskStatus.RUNNING )
			{
				if( workflow.rootTask.exitStatus.code == ExitStatus.ABORTED )
				{
					inProcessor.resume();
					return;
				}
				else
				{
					inProcessor.suspend();
					workflow.addEventListener( WorkflowEvent.COMPLETED, onTaskComplete );
					_commandsCache[ UIDUtil.getUID( workflow ) ] = inProcessor;
					workflow.addEventListener( WorkflowEvent.COMPLETED, onTaskComplete );
				}
			}
			else
			{
				inProcessor.cancel();
			}
		}

		public function resultOverride( 
			inResult : Object, 
			inMessage : Object, 
			inProcessor : CommandObserverProcessor ) : void
		{
			if( !enabled )
				return;
			var aWorkflow : IWorkflow = resolveWorkflow();
			var outResult : * = aWorkflow.run( inResult );

			if( outResult == undefined )
			{
				inProcessor.suspend();
				aWorkflow.addEventListener( WorkflowEvent.COMPLETED, onTaskComplete );
				_commandsCache[ UIDUtil.getUID( aWorkflow ) ] = inProcessor;
				aWorkflow.addEventListener( WorkflowEvent.COMPLETED, onTaskComplete );
			}
			else
				inProcessor.command.setResult( outResult );
		}

		/**
		 * @private
		 */
		private function onTaskComplete( inEvent : WorkflowEvent ) : void
		{
			var workflow : ITasksGroup = ITasksGroup( inEvent.target );
			IEventDispatcher( workflow ).removeEventListener(
				WorkflowEvent.COMPLETED,
				onTaskComplete );
			var processor : CommandObserverProcessor;

			if( behaviour == "command" )
			{
				var token : AsyncToken = 
					_commandsCache[ UIDUtil.getUID( inEvent.target ) ] as AsyncToken;
				setTimeout( function() : void
				{
					token.mx_internal::applyResult(
						new ResultEvent(
						ResultEvent.RESULT,
						false,
						true,
						ITasksGroup( inEvent.target ).output ) );
				}, 1 );
			}
			else if( behaviour == "resultOverride" )
			{
				processor = 
					_commandsCache[ UIDUtil.getUID( inEvent.target ) ] 
					as CommandObserverProcessor;
				processor.command.setResult( inEvent.data );
				processor.resume();
			}
			else if( behaviour == "managed" )
			{
				processor = 
					_commandsCache[ UIDUtil.getUID( inEvent.target ) ] 
					as CommandObserverProcessor;

				if( workflow.exitStatus.code == ExitStatus.ABORTED )
					processor.resume();
				else
					processor.cancel();
			}
			delete _commandsCache[ inEvent.target ];

		}

		private function registerMessageListener() : void
		{
			var info : MessageReceiverInfo = new MessageReceiverInfo();
			info.selector = selector;
			info.type = ClassInfo.forClass( messageType );
			info.order = int.MAX_VALUE;

			if( behaviour == "managed" )
			{
				var handler : DefaultMessageHandler = new DefaultMessageHandler( info );
				handler.init( 
					Provider.forInstance( this ), 
					ClassInfo.forInstance( this )
					.getMethod( "managedHandler" ) );
				_parsleyContext.scopeManager.getScope( scope ).messageReceivers.addTarget( handler );
			}

			if( behaviour == "command" )
			{
				var cHandler : DefaultMessageHandler = new DefaultMessageHandler( info );
				cHandler.init( 
					Provider.forInstance( this ), 
					ClassInfo
					.forInstance( this )
					.getMethod( "commandHandler " ) );
				_parsleyContext
					.scopeManager
					.getScope( scope )
					.messageReceivers
					.addTarget( cHandler );
			}
			else if( behaviour == "messageHandler" )
			{
				var mHandler : DefaultMessageHandler = new DefaultMessageHandler( info );
				mHandler.init( 
					Provider.forInstance( this ), 
					ClassInfo
					.forInstance( this )
					.getMethod( "handler" ) );
				_parsleyContext
					.scopeManager
					.getScope( scope )
					.messageReceivers
					.addTarget( mHandler );
			}
			else if( behaviour == "resultOverride" )
			{
				var observer : DefaultCommandObserver = new DefaultCommandObserver(
					info,
					MessageReceiverKind.COMMAND_COMPLETE_BY_TRIGGER,
					true );
				observer.init(
					Provider.forInstance( this ),
					ClassInfo.forInstance( this ).getMethod( "resultOverride" ) );

				_parsleyContext
					.scopeManager
					.getScope( scope )
					.messageReceivers
					.addCommandObserver( observer );
			}
		}

		/**
		 * @private
		 *
		 * returns an instance of the workflow.
		 * If the workflow is defined in the parsley context as a dynamic object
		 * a pooled instance is retrieved from the factory.
		 */
		private function resolveWorkflow() : IWorkflow
		{
			var actualWorkflow : IWorkflow;
			var objDef : ObjectDefinition;

			if( taskRefId )
			{
				objDef = _parsleyContext.findDefinition( taskRefId );

				if( objDef is DynamicObjectDefinition )
					actualWorkflow = _factory.getInstance( objDef.type.getClass() );
				else
					actualWorkflow = IWorkflow( _parsleyContext.getObject( taskRefId ) );
			}
			else if( workflow is IWorkflow )
			{
				objDef = _parsleyContext.findDefinitionByType( getClass( workflow ) );

				if( objDef is DynamicObjectDefinition )
					actualWorkflow = _factory.getInstance( objDef.type.getClass() );
				else
					actualWorkflow = workflow;
			}

			if( inputFilter )
				IIODataTransformerClient( actualWorkflow ).inputFilter = inputFilter;
			return actualWorkflow;
		}
	}
}
