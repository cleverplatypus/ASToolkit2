package org.astoolkit.workflow.internals
{

	import org.astoolkit.commons.conditional.api.IExpressionResolver;
	import org.astoolkit.commons.eval.ExpressionResolverToken;
	import org.astoolkit.workflow.api.IWorkflowContext;

	[Deprecated(message="WorkflowExpressionResolver is deprecated, use new IExpressionResolver architecture")]
	public class WorkflowExpressionResolver implements IExpressionResolver
	{

		private var _context : IWorkflowContext;

		public function set delegate(inDelegate:IExpressionResolver) : void
		{
			// TODO Auto Generated method stub

		}

		public function set key(inValue:*) : void
		{
			// TODO Auto Generated method stub

		}

		public function set expression(inValue:Object) : void
		{
			// TODO Auto Generated method stub

		}

		public function WorkflowExpressionResolver( inContext : IWorkflowContext )
		{
			_context = inContext;
		}

		public function bindToEnvironment( inEnv : Object, inExpression : Object ) : Object
		{
			inEnv.variables = _context.variables;

			if( inExpression is String )
			{
				var exp : String =
					"namespace core=\"org.astoolkit.workflow.core\";\n" +
					"use namespace core;\n" +
					inExpression as String;
				return exp.replace( /\$\.?\b\w+\b/g, replaceVariables );
			}
			return null;
		}

		public function configEnv( inEnv : Object ) : void
		{
			inEnv.variables = _context.variables;
		}

		/*public function preProcess( inValue : Object ) : Object
		{
			if( inValue is String )
			{
				var exp : String = inValue as String;
				return exp.replace( /\$\b\w+\b/g, replaceVariables );
			}
			return null;
		}*/

		public function resolve( inValue : Object = null, inSource : Object = null ) : ExpressionResolverToken
		{
			/*if( inValue is String )
			{
				var exp : String = inValue as String;

				if( exp.match( /^\$?\w+$/ ) )
					return _context.variables[ exp ];

				if( exp == "." )
					return inSource;

				if( inSource != null && exp.match( /^\w+(\.\w+)*$/ ) )
				{

					for each( var k : String in exp.split( "." ) )
					{
						inSource = inSource[ k ];
					}
					return inSource;
				}
				return inValue;
			}

			if( inValue is Number || inValue is int || inValue is uint || inValue is Boolean )
				return inValue;*/
			return null;
		}

		private function replaceVariables(
			inFound : String,
			inPosition : int,
			inWholeText : String ) : String
		{
			return "$ENV{variables." + inFound + "}";
		}
	}
}
