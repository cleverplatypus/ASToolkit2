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
	import org.astoolkit.commons.factory.IPooledFactory;
	import org.astoolkit.commons.factory.PooledFactory;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.core.WorkflowEvent;
	import org.spicefactory.lib.reflect.ClassInfo;
	import org.spicefactory.parsley.core.context.Context;
	import org.spicefactory.parsley.core.context.provider.Provider;
	import org.spicefactory.parsley.core.messaging.command.CommandObserverProcessor;
	import org.spicefactory.parsley.core.messaging.command.CommandStatus;
	import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
	import org.spicefactory.parsley.core.registry.ObjectDefinition;
	import org.spicefactory.parsley.core.scope.ScopeName;
	import org.spicefactory.parsley.processor.messaging.receiver.DefaultCommandObserver;
	import org.spicefactory.parsley.processor.messaging.receiver.DefaultCommandTarget;
	import org.spicefactory.parsley.processor.messaging.receiver.MessageHandler;
	
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
	[DefaultProperty( "workflow" )]
	public class MessageDrivenTaskTrigger implements IMXMLObject
	{
		public var enabled : Boolean = true;
		
		public var inputFilter : Object;
		
		public var messageType : Class;
		
		public var scope : String  = ScopeName.GLOBAL;
		
		public var selector : * = undefined;
		
		public var taskRefId : String;
		
		[Inspectable( enumeration="message,command,resultOverride" )]
		public var type : String = "message";
		
		public var workflow : IWorkflow;
		
		private var _commandTokens : Object = {};
		
		private var _context : Context;
		
		private var _factory : IPooledFactory;
		
		private var _id : String;
		
		public function commandHandler( inMessage : Object ) : AsyncToken
		{
			if(!enabled)
				return null;
			var task : IWorkflow = resolveTask( inMessage );
			var token : AsyncToken = new AsyncToken();
			_commandTokens[UIDUtil.getUID( task )] = token;
			setTimeout( task.begin, 1 );
			return token;
		}
		
		[Inject]
		public function set context( inContext : Context ) : void
		{
			_context = inContext;
			_factory = new PooledFactory();
			_factory.backupProperties = [ "inputFilter" ];
			_factory.delegate = new DynamicPoolFactoryDelegate( newWorkflowInstance );
		}
		
		public function handler( inMessage : Object ) : void
		{
			if(!enabled)
				return;
			resolveTask( inMessage ).begin();
		}
		
		public function initialized( inDocument : Object, inId : String ) : void
		{
			_id = inId;
			setTimeout( registerMessageListener, 1 );
		}
		
		public function resultOverride( inResult : Object, inMessage : Object, inProcessor : CommandObserverProcessor ) : void
		{
			if(!enabled)
				return;
			var task : IWorkflow = resolveTask( inMessage );
			var outResult : * = task.run( inResult );
			
			if(outResult == undefined)
			{
				inProcessor.suspend();
				task.addEventListener( WorkflowEvent.COMPLETED, onTaskComplete );
				task.context.data["interceptorProcessor"] = inProcessor;
				task.addEventListener( WorkflowEvent.COMPLETED, onTaskComplete );
			}
			else
				inProcessor.command.setResult( outResult );
		}
		
		private function newWorkflowInstance( inClass : Class, inProperties : Object ) : Object
		{
			var outTask : IWorkflow = IWorkflow(
				_context.createDynamicObjectByType(
				inClass ).instance );
			return outTask;
		}
		
		private function onTaskComplete( inEvent : WorkflowEvent ) : void
		{
			IWorkflow( inEvent.target ).removeEventListener(
				WorkflowEvent.COMPLETED,
				onTaskComplete );
			
			if(type == "command")
			{
				var token : AsyncToken = _commandTokens[UIDUtil.getUID( inEvent.target )] as AsyncToken;
				setTimeout( function() : void
				{
					token.mx_internal::applyResult(
						new ResultEvent(
						ResultEvent.RESULT,
						false,
						true,
						IWorkflow( inEvent.target ).output ));
				}, 1 );
				delete _commandTokens[inEvent.target];
			}
			else if(type == "resultOverride")
			{
				var processor : CommandObserverProcessor =
					IWorkflow( inEvent.target ).context.data["interceptorProcessor"];
				processor.command.setResult( IWorkflow( inEvent.target ).output );
				processor.resume();
			}
		}
		
		private function registerMessageListener() : void
		{
			if(type == "command")
			{
				_context.scopeManager.getScope( scope ).messageReceivers.addTarget(
					new DefaultCommandTarget(
					Provider.forInstance( this ),
					"commandHandler",
					selector,
					ClassInfo.forClass( messageType )));
			}
			else if(type == "message")
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
			else if(type == "resultOverride")
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
		private function resolveTask( inMessage : Object ) : IWorkflow
		{
			var actualWorkflow : IWorkflow;
			var objDef : ObjectDefinition;
			
			if(taskRefId)
			{
				objDef = _context.findDefinition( taskRefId );
				
				if(objDef is DynamicObjectDefinition)
					actualWorkflow = _factory.getInstance( objDef.type.getClass());
				else
					actualWorkflow = IWorkflow( _context.getObject( taskRefId ));
			}
			else if(workflow is IWorkflow)
			{
				objDef = _context.findDefinitionByType(
					getDefinitionByName(
					getQualifiedClassName( workflow )) as Class );
				
				if(objDef is DynamicObjectDefinition)
					actualWorkflow = _factory.getInstance( objDef.type.getClass());
				else
					actualWorkflow = workflow;
			}
			
			if(inputFilter)
				actualWorkflow.inputFilter = inputFilter;
			actualWorkflow.input = inMessage;
			return actualWorkflow;
		}
	}
}
