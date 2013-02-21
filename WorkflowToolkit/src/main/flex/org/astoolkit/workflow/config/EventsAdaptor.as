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
package org.astoolkit.workflow.config
{

	import flash.events.EventDispatcher;

	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.core.ExitStatus;

	[Event(
		name = "started",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "warning",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "fault",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "completed",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "progress",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "prepare",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	public class EventsAdaptor extends EventDispatcher implements ITaskLiveCycleWatcher
	{

		public function get taskWatcherPriority() : int
		{
			return 0;
		}

		public function set taskWatcherPriority( inValue : int ) : void
		{
		}

		public function onTaskPhase( inTask : IWorkflowTask, inPhase : String, inData : * = undefined ) : void
		{

		}


	}
}
