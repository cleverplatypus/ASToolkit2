package org.astoolkit.commons.eval.api
{

	public interface IRuntimeExpressionEvaluatorRegistry
	{
		function getEvaluator( inExpression : String, inType : Class = null ) : IRuntimeExpressionEvaluator;
		function registerEvaluator( inObject : Object ) : void;
	}
}
