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
package org.astoolkit.workflow.internals
{
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import org.astoolkit.workflow.api.IWorkflowTask;
	
	[Event( name="complete", type="flash.events.Event" )]
	[Event( name="error", type="flash.events.ErrorEvent" )]
	public class HeldTaskInfo extends EventDispatcher
	{
		public function HeldTaskInfo( inTask : IWorkflowTask )
		{
			super( this );
			_task = inTask;
		}
		
		private var _task : IWorkflowTask;
		
		public function release( inError : Error = null ) : void
		{
			if ( inError )
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, inError.getStackTrace() ) );
			else
				dispatchEvent( new Event( Event.COMPLETE ) );
		}
	}
}
