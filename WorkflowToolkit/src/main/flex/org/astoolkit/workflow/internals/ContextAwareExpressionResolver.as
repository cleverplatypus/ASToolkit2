package org.astoolkit.workflow.internals
{

	import flash.utils.getQualifiedClassName;
	import mx.logging.ILogger;
	import org.astoolkit.commons.eval.ExpressionResolverResult;
	import org.astoolkit.commons.eval.Resolve;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.workflow.api.IWorkflowContext;

	public class ContextAwareExpressionResolver extends Resolve implements IContextAwareElement
	{
		private const LOGGER : ILogger = getLogger( ContextAwareExpressionResolver );

		protected var _context : IWorkflowContext;

		public function get context() : IWorkflowContext
		{
			return _context;
		}

		public function set context(inValue:IWorkflowContext) : void
		{
			_context = inValue;
		}

		override public function resolve( inExpression : Object = null, inSource : Object = null ) : ExpressionResolverResult
		{
			var expr : Object = _expression ? _expression : inExpression;

			var out : ExpressionResolverResult;

			if( expr is String && String( expr ).match( /^\$\w+(\.w+)*$/ ) )
			{
				var dest : * = _context.variables;
				out = new ExpressionResolverResult();

				for each( var segment : String in String( expr ).split( "." ) )
				{
					if( !segment.match( /^\$/ ) && ( dest == null || !dest.hasOwnProperty( segment ) ) )
					{
						LOGGER.warn( 
							"Property '{0}' not found in class {0}", 
							segment, 
							getQualifiedClassName( dest ) );
						return null;
					}
					dest = dest[ segment ];
				}
				out.result = dest;
			}
			return out;
		}
	}
}
