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
	
	import flash.utils.setTimeout;
	import org.astoolkit.workflow.constant.TaskStatus;
	import org.astoolkit.workflow.core.BaseTask;
	
	public class WatchValue extends BaseTask
	{
		public var condition : Object;
		
		[Inspectable( defaultValue="change", enumeration="value,change,condition" )]
		public var trigger : String;
		
		public var value : Object;
		
		public function set source( inValue : * ) : void
		{
			/*
				this is necessary to make sure that a condition
				set as a Boolean fed by data binding
				is executed before handling the source binding
			*/
			setTimeout( handleBinding, 1, inValue );
		}
		
		private function handleBinding( inValue : * ) : void
		{
			if(status != TaskStatus.RUNNING)
				return;
			
			if(trigger == "change")
				complete();
			else if(trigger == "value" && inValue == value)
				complete();
			else if(trigger == "condition")
			{
				if(condition is Boolean && condition)
					complete();
				else if(condition is Function && condition() == true)
					complete();
				else if(!(condition is Boolean || condition is Function))
					fail( "Watch condition set to a value other than Boolean or Function returning a Boolean" );
			}
		}
	}
}
