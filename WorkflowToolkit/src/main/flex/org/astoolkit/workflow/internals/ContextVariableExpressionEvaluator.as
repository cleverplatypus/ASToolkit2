package org.astoolkit.workflow.internals
{

	import org.astoolkit.commons.eval.api.IRuntimeExpressionEvaluator;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.workflow.api.IWorkflowContext;

	public class ContextVariableExpressionEvaluator implements IRuntimeExpressionEvaluator, IContextAwareElement
	{

		private var _context : IWorkflowContext;

		private var _priority : int = 1000;

		private var _varName : String;

		public function get async() : Boolean
		{
			return false;
		}

		public function set context( inValue : IWorkflowContext ) : void
		{
			_context = inValue;
		}

		public function eval() : Object
		{
			return _context.variables[ _varName ];
		}

		public function get priority() : int
		{
			return _priority;
		}

		public function set priority( value : int ) : void
		{
			_priority = value;
		}

		public function set runtimeExpression( inValue : String ) : void
		{
			_varName = inValue;
		}

		public function supportsExpression( inExpression : String ) : Boolean
		{
			return inExpression && inExpression.match( /^\$[_A-Z0-9]+$/i );
		}
	}
}
