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

	import flash.utils.getQualifiedClassName;
	import org.spicefactory.parsley.core.command.CommandStatus;
	import org.spicefactory.parsley.core.messaging.MessageReceiverKind;
	import org.spicefactory.parsley.core.messaging.receiver.CommandObserver;

	public class ObserveCommand extends AbstractParsleyTask
	{

		private var _observer : CommandObserver;

		[Inspectable( enumeration="complete,fail", defaultValue="complete" )]
		public var behaviour : String;

		public var messageType : Class;

		[Inspectable( enumeration="execute,error,complete,cancel", defaultValue="complete" )]
		public var phase : String;

		public var selector : *;

		override public function begin() : void
		{
			super.begin();
			var status : CommandStatus;

			switch( phase )
			{
				case "execute":
					status = CommandStatus.EXECUTE;
					break;
				case "error":
					status = CommandStatus.ERROR;
					break;
				case "complete":
					status = CommandStatus.COMPLETE;
					break;
				case "cancel":
					status = CommandStatus.CANCEL;
					break;
			}
			_observer = this.createThreadSafeObserver( status, selector, messageType, 1, onMessage );
			_parsleyContext
				.scopeManager
				.getScope( scope as String )
				.messageReceivers
				.addCommandObserver( _observer );
		}

		private function onMessage( ... inArgs ) : void
		{
			var message : Object;

			switch( phase )
			{
				case "execute":
				case "cancel":
					message = inArgs[ 0 ];
					break;
				default:
					message = inArgs[ 1 ];
			}

			if( behaviour == "complete" )
				complete();
			else
				fail(
					"Failed on message {0} reception",
					getQualifiedClassName( message ) );
		}
	}
}
