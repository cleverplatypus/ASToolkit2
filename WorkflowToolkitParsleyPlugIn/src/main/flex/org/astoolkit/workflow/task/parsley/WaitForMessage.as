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
	import mx.core.IFactory;
	
	import org.spicefactory.lib.reflect.ClassInfo;
	import org.spicefactory.parsley.core.context.provider.Provider;
	import org.spicefactory.parsley.core.messaging.receiver.MessageTarget;
	import org.spicefactory.parsley.processor.messaging.receiver.MessageHandler;
	

	public class WaitForMessage extends AbstractParsleyTask
	{
		public var messageType : IFactory;
		public var selector : String;
		
		private var _messageTarget : MessageTarget;
		
		override public function begin() : void
		{
			super.begin();
			var listener : Listener = new Listener( onMessage );
			_messageTarget = 
				new MessageHandler(
					Provider.forInstance( listener ), 
					"handler", 
					selector,
					ClassInfo.forClass( Listener )
				)					
			parsleyContext
				.scopeManager
				.getScope( scope as String )
				.messageReceivers
				.addTarget( _messageTarget );
			

		}

		private function onMessage() : void
		{
			parsleyContext
				.scopeManager
				.getScope( scope as String )
				.messageReceivers
				.removeTarget( _messageTarget );
			_messageTarget = null;
			complete();
		}
		

	}
}

class Listener
{
	private var _callback : Function;
	
	public function Listener( inCallback : Function ) 
	{
		_callback = inCallback;
	}
	
	public function handler( inMessage : Object ) : void
	{
		_callback();
	}
}