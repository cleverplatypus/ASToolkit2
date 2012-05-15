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
package org.astoolkit.workflow.task.parsley
{
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.api.IContextPlugIn;
	import org.astoolkit.workflow.plugin.ParsleyPlugIn;
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.spicefactory.parsley.core.context.Context;
	import org.spicefactory.parsley.core.messaging.command.CommandStatus;
	import org.spicefactory.parsley.core.messaging.receiver.CommandObserver;
	
	public class AbstractParsleyTask extends BaseTask
	{
		protected var _parsleyHelper : ParsleyPlugIn;
		private var _parsleyContext : Context;
		
		public var scope : String;
		
		public function AbstractParsleyTask()
		{
			super();
			if( getQualifiedClassName( this ) == getQualifiedClassName( AbstractParsleyTask ) )
				throw new Error( getQualifiedClassName( this ) + " is an abstract class." );
		}
		
		protected function registerCommandObserver( inObserver : CommandObserver ) : void
		{
			parsleyContext
			.scopeManager
				.getScope( scope )
				.messageReceivers
				.addCommandObserver( inObserver );
		}
		
		protected function unregisterCommandObserver( inObserver : CommandObserver ) : void
		{
			parsleyContext
			.scopeManager
				.getScope( scope )
				.messageReceivers
				.removeCommandObserver( inObserver );
		}
		
		override public function initialize():void
		{
			super.initialize();
			if( !parsleyContext ) 
			{
				fail( getQualifiedClassName( this ) + " cannot be ran because the provided " +
					"implementation of IWorkflowContext doesn't provide access to an instance of " +
					"ParsleyMessageBusHelper" );
				return;
			}
		}

		
		protected function createThreadSafeObserver(
			inStatus : CommandStatus, 
			inSelector : *, 
			inMessageType : Class,
			inOrder : int,
			inHandler : Function ) : CommandObserver
		{
			return new Observer(
				inStatus,
				inSelector,
				inMessageType,
				inOrder,
				threadSafe( inHandler ) )
		}
		
		
		protected function get parsleyContext() : Context
		{
			if( !_parsleyContext )
			{
				for each( var plugIn : IContextPlugIn in _context.plugIns )
				{
					if( plugIn is ParsleyPlugIn )
					{
						_parsleyContext = ParsleyPlugIn( plugIn ).context;
						break;
					}
				}
			}
			return _parsleyContext;
		}

	}
}
import mx.rpc.AsyncToken;
import mx.rpc.events.FaultEvent;
import mx.rpc.events.ResultEvent;
import mx.utils.ObjectUtil;

import org.spicefactory.parsley.core.messaging.command.CommandObserverProcessor;
import org.spicefactory.parsley.core.messaging.command.CommandStatus;
import org.spicefactory.parsley.core.messaging.receiver.CommandObserver;

class Observer implements CommandObserver
{
	private var _status : CommandStatus;
	private var _selector : *;
	private var _handler : Function;
	private var _messageType : Class;
	private var _order : int;
	
	public function Observer( 
		inStatus : CommandStatus, 
		inSelector : *, 
		inMessageType : Class,
		inOrder : int,
		inHandler : Function)
	{
		_status = inStatus;
		_selector = inSelector;
		_messageType = inMessageType;
		_handler = inHandler;
		_order = inOrder
	}
	
	public function get messageType():Class
	{
		return _messageType;
	}
	
	public function get order():int
	{
		return _order;
	}
	
	public function get selector():*
	{
		return _selector;
	}
	
	
	public function observeCommand( 
		inProcessor : CommandObserverProcessor ) : void
	{
		var returnValue : Object = inProcessor.command.returnValue; 
		if( status.key == CommandStatus.COMPLETE.key )
		{
			var result : Object = 
				returnValue is AsyncToken ?  
					ResultEvent( AsyncToken( returnValue ).result ).result : returnValue;
				_handler( result, inProcessor.message );
		}
		else if( status.key == CommandStatus.ERROR.key )
		{
			var text : String = returnValue is AsyncToken ?  
				FaultEvent( AsyncToken( returnValue).result ).fault.getStackTrace() : 
				ObjectUtil.toString( returnValue );
			_handler( text, inProcessor.message );
		}
		else
			_handler( inProcessor.message );

	}
	
	public function get status():CommandStatus
	{
		return _status;
	}
}