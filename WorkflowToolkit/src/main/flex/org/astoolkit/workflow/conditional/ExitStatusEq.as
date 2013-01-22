package org.astoolkit.workflow.conditional
{

	import org.astoolkit.commons.conditional.Eq;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.workflow.api.IWorkflowContext;

	[XDoc("2.1")]
	public class ExitStatusEq extends Eq implements IContextAwareElement
	{
		private var _context : IWorkflowContext;

		public function get context() : IWorkflowContext
		{
			return _context;
		}

		public function set context( inValue : IWorkflowContext ) : void
		{
			_context = inValue;
		}

		override public function evaluate( inComparisonValue : * = null ) : Object
		{
			if( _lastResult !== undefined )
				return _lastResult;
			_lastResult = negateSafeResult( _context.variables.$exitStatus.code == to );
			return _lastResult;
		}
	}
}
