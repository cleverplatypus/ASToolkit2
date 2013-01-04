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
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.core.IMXMLObject;
	import mx.core.mx_internal;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	import mx.utils.UIDUtil;
	
	import org.astoolkit.commons.factory.DynamicPoolFactoryDelegate;
	import org.astoolkit.commons.factory.PooledFactory;
	import org.astoolkit.commons.factory.api.IPooledFactory;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerClient;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.constant.TaskStatus;
	import org.astoolkit.workflow.core.ExitStatus;
	import org.astoolkit.workflow.core.WorkflowEvent;
	import org.spicefactory.lib.reflect.ClassInfo;
	import org.spicefactory.parsley.core.context.Context;
	import org.spicefactory.parsley.core.context.provider.Provider;
	import org.spicefactory.parsley.core.messaging.MessageProcessor;
	import org.spicefactory.parsley.core.messaging.command.CommandObserverProcessor;
	import org.spicefactory.parsley.core.messaging.command.CommandStatus;
	import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
	import org.spicefactory.parsley.core.registry.ObjectDefinition;
	import org.spicefactory.parsley.core.scope.ScopeName;
	import org.spicefactory.parsley.processor.messaging.receiver.DefaultCommandObserver;
	import org.spicefactory.parsley.processor.messaging.receiver.DefaultCommandTarget;
	import org.spicefactory.parsley.processor.messaging.receiver.MessageHandler;
	
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
		//TODO: only allow workflow reference by class or refId
		public var enabled : Boolean = true;
		
		public var inputFilter : Object;
		
		public var messageType : Class;
		
		public var scope : String  = ScopeName.GLOBAL;
		
		public var selector : * = undefined;
		
		public var taskRefId : String;
		
		[Inspectable( enumeration="messageHandler,command,resultOverride,managed" )]
		public var behaviour : String = "messageHandler";
		
		public var workflow : IWorkflow;
		
		public var workflowType : Class;
		
		private var _commandsCache : Object = {};
		
		private var _context : Context;
		
		private var _factory : IPooledFactory;
		
		private var _id : String;
		
		public function commandHandler( inMessage : Object ) : AsyncToken
		{
			if ( !enabled )
				return null;
			var aWorkflow : IWorkflow = resolveWorkflow();
			var token : AsyncToken = new AsyncToken();
			_commandsCache[ UIDUtil.getUID( aWorkflow ) ] = token;
			setTimeout( aWorkflow.run, 1, inMessage );
			return token;
		}
		
		[Inject]
		public function set context( inContext : Context ) : void
		{
			_context = inContext;
			_factory = new PooledFactory();
			_factory.backupProperties = [ "inputFilter" ];
			var parsleyContextFactory : ParsleyContextObjectFactory = new ParsleyContextObjectFactory();
			parsleyContextFactory.context = _context;
			parsleyContextFactory.singletonInstance = false;
			_factory.delegate = new DynamicPoolFactoryDelegate( parsleyContextFactory );
		}
		
		public function handler( inMessage : Object ) : void
		{
			if ( !enabled )
				return;
			resolveWorkflow().run( inMessage );
		}
		
		public function initialized( inDocument : Object, inId : String ) : void
		{
			_id = inId;
			setTimeout( registerMessageListener, 1 );
		}
		
		public function managedHandler( inMessage : Object, inProcessor : MessageProcessor ) : void
		{
			if ( !enabled )
				return;
			var workflow : IWorkflow = resolveWorkflow();
			var outResult : * = workflow.run( inMessage );
			
			if ( workflow.context.status != TaskStatus.RUNNING )
			{
				if ( workflow.rootTask.exitStatus.code == ExitStatus.ABORTED )
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
		
		public function resultOverride( inResult : Object, inMessage : Object, inProcessor : CommandObserverProcessor ) : void
		{
			if ( !enabled )
				return;
			var aWorkflow : IWorkflow = resolveWorkflow();
			var outResult : * = aWorkflow.run( inResult );
			
			if ( outResult == undefined )
			{
				inProcessor.suspend();
				aWorkflow.addEventListener( WorkflowEvent.COMPLETED, onTaskComplete );
				_commandsCache[ UIDUtil.getUID( aWorkflow ) ] = inProcessor;
				aWorkflow.addEventListener( WorkflowEvent.COMPLETED, onTaskComplete );
			}
			else
				inProcessor.command.setResult( outResult );
		}
		
		private function onTaskComplete( inEvent : WorkflowEvent ) : void
		{
			var workflow : ITasksGroup = ITasksGroup( inEvent.target );
			workflow.removeEventListener(
				WorkflowEvent.COMPLETED,
				onTaskComplete );
			var processor : CommandObserverProcessor;
			
			if ( behaviour == "command" )
			{
				var token : AsyncToken = _commandsCache[ UIDUtil.getUID( inEvent.target ) ] as AsyncToken;
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
			else if ( behaviour == "resultOverride" )
			{
				processor = _commandsCache[ UIDUtil.getUID( inEvent.target ) ] as CommandObserverProcessor;
				processor.command.setResult( inEvent.data );
				processor.resume();
			}
			else if ( behaviour == "managed" )
			{
				processor = _commandsCache[ UIDUtil.getUID( inEvent.target ) ] as CommandObserverProcessor;
				
				if ( workflow.exitStatus.code == ExitStatus.ABORTED )
					processor.resume();
				else
					processor.cancel();
			}
			delete _commandsCache[ inEvent.target ];

		}
		
		private function registerMessageListener() : void
		{
			if ( behaviour == "managed" )
			{
				_context.scopeManager.getScope( scope ).messageReceivers.addTarget(
					new MessageHandler(
					Provider.forInstance( this ),
					"managedHandler",
					selector,
					ClassInfo.forClass( messageType ),
					null,
					int.MAX_VALUE ) );
			}
			
			if ( behaviour == "command" )
			{
				_context.scopeManager.getScope( scope ).messageReceivers.addTarget(
					new DefaultCommandTarget(
					Provider.forInstance( this ),
					"commandHandler",
					selector,
					ClassInfo.forClass( messageType ) ) );
			}
			else if ( behaviour == "messageHandler" )
			{
				_context.scopeManager.getScope( scope ).messageReceivers.addTarget(
					new MessageHandler(
					Provider.forInstance( this ),
					"handler",
					selector,
					ClassInfo.forClass( messageType )
					)
					);
			}
			else if ( behaviour == "resultOverride" )
			{
				_context.scopeManager.getScope( scope ).messageReceivers.addCommandObserver(
					new DefaultCommandObserver(
					Provider.forInstance( this ),
					"resultOverride",
					CommandStatus.COMPLETE,
					selector,
					ClassInfo.forClass( messageType )
					)
					);
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
			
			if ( taskRefId )
			{
				objDef = _context.findDefinition( taskRefId );
				
				if ( objDef is DynamicObjectDefinition )
					actualWorkflow = _factory.getInstance( objDef.type.getClass() );
				else
					actualWorkflow = IWorkflow( _context.getObject( taskRefId ) );
			}
			else if ( workflow is IWorkflow )
			{
				objDef = _context.findDefinitionByType(
					getDefinitionByName(
					getQualifiedClassName( workflow ) ) as Class );
				
				if ( objDef is DynamicObjectDefinition )
					actualWorkflow = _factory.getInstance( objDef.type.getClass() );
				else
					actualWorkflow = workflow;
			}
			
			if ( inputFilter )
				IIODataTransformerClient( actualWorkflow ).inputFilter = inputFilter;
			return actualWorkflow;
		}
	}
}
