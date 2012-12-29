package org.astoolkit.workflow.task.flowcontrol
{

	import org.astoolkit.workflow.api.ITasksFlow;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.internals.GroupUtil;

	public class LastIteration extends BaseTask
	{
		public var atCount : uint = 0;

		private var _currentCount : uint = 0;

		private var _lastParentThread : uint;

		override public function begin() : void
		{
			super.begin();

			if( !_currentIterator )
			{
				fail( "Task {0} isn't inside a valid iteration", description );
			}
			_currentCount++;

			if( atCount == _currentCount )
			{
				_currentIterator.abort();
			}
			complete();
		}

		override public function prepare() : void
		{
			super.prepare();
			var p : ITasksFlow = GroupUtil.getParentWorkflow( this );

			if( _lastParentThread != p.currentThread )
			{
				_lastParentThread = p.currentThread;
				_currentCount = 0;
			}
		}
	}
}
