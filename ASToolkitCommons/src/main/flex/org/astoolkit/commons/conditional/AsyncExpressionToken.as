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
package org.astoolkit.commons.conditional
{

	import flash.events.Event;
	import flash.events.EventDispatcher;

	[Event( name="complete", type="flash.events.Event" )]
	public class AsyncExpressionToken extends EventDispatcher
	{

		private var _result : *;

		public function complete( inResult : * ) : void
		{
			_result = inResult;
			dispatchEvent( new Event( Event.COMPLETE ) );
		}

		public function get result() : *
		{
			return _result;
		}
	}
}
