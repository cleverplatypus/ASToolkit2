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
package org.astoolkit.workflow.task.net
{

	import mx.messaging.ChannelSet;
	import mx.rpc.AbstractOperation;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.remoting.RemoteObject;
	import org.astoolkit.workflow.core.BaseTask;

	public class InvokeRemoteProcedure extends BaseTask
	{
		public var channelSet : ChannelSet;

		public var destination : String;

		public var ignoreResult : Boolean = true;

		public var methodName : String;

		public var params : Array;

		public var remoteObject : RemoteObject;

		public var result : *;

		override public function begin() : void
		{
			super.begin();
			remoteObject = new RemoteObject();
			remoteObject.destination = destination;
			remoteObject.channelSet = channelSet;
			var op : AbstractOperation = remoteObject.getOperation( methodName );

			if( params && params.length > 0 )
			{
				var paramsObj : Object = {};

				for( var i : int = 0; i < params.length; i++ )
				{
					paramsObj[ "p" + i ] = params[ i ];
				}
			}
			var token : AsyncToken = op.send();

			if( ignoreResult )
			{
				complete();
			}
			else
			{
				token.addResponder( new Responder( threadSafe( onResult ), threadSafe( onFault ) ) );
			}
		}

		override public function prepare() : void
		{
			super.prepare();
			result = null;
		}

		private function onFault( inEvent : FaultEvent ) : void
		{
			fail( inEvent.fault.message, inEvent.fault );
		}

		private function onResult( inEvent : ResultEvent ) : void
		{
			result = inEvent.result;
			complete( result );
		}
	}
}
