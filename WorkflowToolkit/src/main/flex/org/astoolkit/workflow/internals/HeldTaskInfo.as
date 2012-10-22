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
			if( inError )
				dispatchEvent( new ErrorEvent( ErrorEvent.ERROR, false, false, inError.getStackTrace() ) );
			else
				dispatchEvent( new Event( Event.COMPLETE ) );
		}
	}
}
