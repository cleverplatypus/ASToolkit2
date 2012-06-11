package org.astoolkit.workflow.task.flowcontrol
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
			
			if(systemManager.mx_internal::idleCounter >= ((idleTime - 1000) / 100))
				complete();
			else
			{
				systemManager.addEventListener(
					FlexEvent.IDLE,
					threadSafe( onIdle ));
			}
		}
		
		override public function initialize() : void
		{
			super.initialize();
			systemManager = UIComponent( FlexGlobals.topLevelApplication ).systemManager;
		}
		
		private function onIdle( inEvent : FlexEvent ) : void
		{
			if(systemManager.mx_internal::idleCounter >= ((idleTime - 1000) / 100))
				complete();
		}
	}
}
