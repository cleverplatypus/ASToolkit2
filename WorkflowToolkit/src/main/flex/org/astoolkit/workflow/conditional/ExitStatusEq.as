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
