package org.astoolkit.commons.eval.api
{

	public interface IRuntimeExpressionEvaluator
	{
		function get async() : Boolean;
		function eval() : Object;
		function get priority() : int;
		function set priority( inValue : int ) : void;
		function set runtimeExpression( inValue : String ) : void;
		function supportsExpression( inExpression : String ) : Boolean;
	}
}
