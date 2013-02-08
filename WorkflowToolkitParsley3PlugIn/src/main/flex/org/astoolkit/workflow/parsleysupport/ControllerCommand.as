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

	import flash.events.ErrorEvent;

	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	/**
	 * Utility class to allow controller classes to handle multiple Parsley commands
	 */
	public class ControllerCommand
	{
		private var _destination : Object;

		private var _destinationFunction : Function;

		public var callback : Function;

		public static function create( inDestination : Object, inDestinationFunction : Function ) : ControllerCommand
		{
			var out : ControllerCommand = new ControllerCommand();

			out._destinationFunction = inDestinationFunction;
			out._destination = inDestination;

			return out;
		}

		public function execute( inMessage : Object ) : void
		{
			var out : AsyncToken =  _destinationFunction.apply( _destination, [ inMessage ] );
			out.addResponder( new Responder( onResult, onError ) );
		}

		private function onResult( inEvent : ResultEvent ) : ResultEvent
		{
			trace( "resulto" );
			callback( inEvent );
			return inEvent;
		}

		private function onError( inEvent : FaultEvent ) : FaultEvent
		{
			trace( "erroro" );
			callback( inEvent );
			return inEvent
		}
	}
}
