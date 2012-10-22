package org.astoolkit.workflow.internals
{

	import flash.utils.getQualifiedClassName;
	import org.astoolkit.commons.eval.api.IRuntimeExpressionEvaluator;
	import org.astoolkit.commons.eval.api.IRuntimeExpressionEvaluatorRegistry;

	public class DefaultRuntimeExpressionEvaluatorRegistry implements IRuntimeExpressionEvaluatorRegistry
	{

		public function DefaultRuntimeExpressionEvaluatorRegistry()
		{
			_evaluators = new Vector.<IRuntimeExpressionEvaluator>();
			registerEvaluator( ContextVariableExpressionEvaluator );
		}

		private var _evaluators : Vector.<IRuntimeExpressionEvaluator>

		public function getEvaluator( inExpression : String, inType : Class = null ) : IRuntimeExpressionEvaluator
		{
			for each( var ev : IRuntimeExpressionEvaluator in _evaluators )
			{
				if( ev.supportsExpression( inExpression ) &&
					( inType == null || ev is inType ) )
					return ev;
			}
			return null;
		}

		public function registerEvaluator( inObject : Object ) : void
		{
			var o : Object = inObject is Class ? new inObject() : inObject;

			if( !( o is IRuntimeExpressionEvaluator ) )
				throw new Error( "Attempt to register unrelated class " +
					getQualifiedClassName( o ) + " as IRuntimeExpressionEvaluator" );
			_evaluators.push( o as IRuntimeExpressionEvaluator );
			_evaluators = _evaluators.sort( sort );
		}

		private function sort( inFilterA : IRuntimeExpressionEvaluator, inFilterB : IRuntimeExpressionEvaluator ) : int
		{
			if( inFilterA.priority < inFilterB.priority )
				return 1;
			else if( inFilterA.priority > inFilterB.priority )
				return -1;
			return 0;
		}
	}
}
