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
