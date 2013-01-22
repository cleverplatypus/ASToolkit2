/*

Copyright 2009 Nicola Dal Pont

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Version 2.x

*/
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

			/*
				TODO: 	Add case where string contains variable references
						e.g. "$myVar == null".
						Implementation should return a ExpressionResolverResult
						with result = undefined, expression changed to something like
						"${myVar} == null" and resolvedSymbols = { myVar : [resolved data] }
			*/

			return out;
		}
	}
}
