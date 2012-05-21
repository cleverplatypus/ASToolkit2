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
package org.astoolkit.workflow.task.events
{
	import org.astoolkit.workflow.core.BaseTask;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	public class WaitForEvent extends BaseTask
	{
		public var target : IEventDispatcher;
		public var eventType : String;
		public var priority : int = int.MIN_VALUE;
		
		override public function prepare():void
		{
			super.prepare();
			if( !target || !eventType ) 
			{
				fail( "No target and/or eventType provided" );
				return;
			}
			target.addEventListener( eventType, onEvent, false, priority );
		}
		
		override public function begin() : void
		{
			super.begin();
		}
		
		private function onEvent( inEvent : Event ) : void
		{
			target.removeEventListener( eventType, onEvent );
			complete();
		}
	}
	
}