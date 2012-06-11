package org.astoolkit.workflow.task.flowcontrol
{

	import org.astoolkit.workflow.api.IWorkflow;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.internals.GroupUtil;

	public class BreakAfterCount extends BaseTask
	{
		public var count : uint = 0;

		private var _currentCount : uint = 0;

		private var _lastParentThread : uint;

		override public function begin() : void
		{
			super.begin();
			_currentCount++;

			if( count == _currentCount )
			{
				var p : IWorkflowElement = parent;

				while( !( p is IWorkflow ) )
					p = p.parent;
				IWorkflow( p ).abort();
				return;
			}
			complete();
		}

		override public function prepare() : void
		{
			super.prepare();
			var p : IWorkflow = GroupUtil.getParentWorkflow( this );

			if( _lastParentThread != p.currentThread )
			{
				_lastParentThread = p.currentThread;
				_currentCount = 0;
			}
		}
	}
}
