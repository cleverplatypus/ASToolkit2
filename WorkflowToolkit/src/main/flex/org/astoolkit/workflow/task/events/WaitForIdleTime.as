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

*/package org.astoolkit.workflow.task.events
{

	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.events.FlexEvent;
	import org.astoolkit.workflow.core.BaseTask;

	use namespace mx_internal;

	public class WaitForIdleTime extends BaseTask
	{
		public var idleTime : int = 200;

		private var systemManager : Object;

		override public function begin() : void
		{
			super.begin();

			if( systemManager.mx_internal::idleCounter >= ( ( idleTime - 1000 ) / 100 ) )
				complete();
			else
			{
				systemManager.addEventListener(
					FlexEvent.IDLE,
					threadSafe( onIdle ) );
			}
		}

		override public function initialize() : void
		{
			super.initialize();
			systemManager = UIComponent( FlexGlobals.topLevelApplication ).systemManager;
		}

		private function onIdle( inEvent : FlexEvent ) : void
		{
			if( systemManager.mx_internal::idleCounter >= ( ( idleTime - 1000 ) / 100 ) )
				complete();
		}
	}
}
