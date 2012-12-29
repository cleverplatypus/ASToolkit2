package org.astoolkit.workflow.conditional
{
	
	import org.astoolkit.commons.conditional.Eq;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.workflow.api.IWorkflowContext;
	
	public class ExitStatusEq extends Eq implements IContextAwareElement
	{
		private var _context : IWorkflowContext;
		
		override public function evaluate( inComparisonValue : * = null ) : Object
		{
			if ( _lastResult !== undefined )
				return _lastResult;
			_lastResult = negateSafeResult( _context.variables.$exitStatus.code == to );
			return _lastResult;
		}
		
		public function set context( inValue : IWorkflowContext ) : void
		{
			_context = inValue;
		}
		
		public function get context() : IWorkflowContext
		{
			return _context;
		}
	}
}