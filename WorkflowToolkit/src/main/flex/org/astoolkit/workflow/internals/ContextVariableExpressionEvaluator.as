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

	import org.astoolkit.commons.eval.api.IRuntimeExpressionEvaluator;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.workflow.api.IWorkflowContext;

	public class ContextVariableExpressionEvaluator implements IRuntimeExpressionEvaluator, IContextAwareElement
	{
		private var _context : IWorkflowContext;

		private var _priority : int = 1000;

		private var _varName : String;

		public function get isAsync() : Boolean
		{
			return false;
		}

		public function set context( inValue : IWorkflowContext ) : void
		{
			_context = inValue;
		}

		public function get context() : IWorkflowContext
		{
			return _context;
		}

		public function eval() : Object
		{
			return _context.variables[ _varName ];
		}

		public function get priority() : int
		{
			return _priority;
		}

		public function set priority( inValue : int ) : void
		{
			_priority = inValue;
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
