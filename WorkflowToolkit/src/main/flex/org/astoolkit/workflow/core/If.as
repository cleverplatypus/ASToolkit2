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
package org.astoolkit.workflow.core
{

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import org.astoolkit.commons.conditional.AsyncExpressionToken;
	import org.astoolkit.commons.conditional.api.IConditionalExpression;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerClient;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	import org.astoolkit.commons.process.api.IDeferrableProcess;
	import org.astoolkit.commons.configuration.api.ISelfWiring;
	import org.astoolkit.workflow.api.*;

	public class If extends BaseElement implements ITaskProxy,
		IDeferrableProcess,
		ISelfWiring,
		IPipelineConsumer,
		IIODataTransformerClient
	{

		private var _cachedConditionResult : Boolean;

		/**
		 * @private
		 */
		private var _condition : Object;

		private var _deferredProcessWatchers : Vector.<Function> = new Vector.<Function>();

		private var _executionIsDeferred : Boolean;

		/**
		 * @private
		 */
		private var _expression : IConditionalExpression;

		private var _input : *;

		private var _inputFilter : Object;

		/**
		 * @private
		 */
		private var _isFalseTask : IWorkflowTask;

		/**
		 * @private
		 */
		private var _isTrueTask : IWorkflowTask;

		/**
		 * @private
		 */
		private var _stringExpression : String;

		[AutoConfig( order = "2" )]
		/**
		 * (optional) the tasks to enable with <code>condition == false</code>
		 */
		public function set Else( inValue : IWorkflowTask ) : void
		{
			_isFalseTask = inValue;
		}

		[AutoConfig( order = "1" )]
		/**
		 * the tasks to enable with <code>condition == true</code>
		 */
		public function set Then( inValue : IWorkflowTask ) : void
		{
			_isTrueTask = inValue;
		}

		[AutoConfig( type = "org.astoolkit.commons.conditional.api.IConditionalExpression" )]
		public function set condition( inValue : Object ) : void
		{
			if( inValue is Boolean )
			{
				_condition = inValue as Boolean;
				applyCondition();
			}
			else if( inValue is String )
			{
				_stringExpression = inValue as String;
			}

			if( inValue is IConditionalExpression )
			{
				_expression = inValue as IConditionalExpression;
			}
		}

		public function set dataTransformerRegistry( inRegistry : IIODataTransformerRegistry ) : void
		{
			// TODO Auto Generated method stub

		}

		public function set input( inData : * ) : void
		{
			_input  = inData;
		}

		public function set inputFilter( inValue : Object ) : void
		{
			_inputFilter  = inValue;
		}

		override public function set parent( inValue : ITasksGroup ) : void
		{
			super.parent = inValue;

			if( _isTrueTask )
				_isTrueTask.parent = inValue;

			if( _isFalseTask )
				_isFalseTask.parent = inValue;

		}

		public function addDeferredProcessWatcher( inWatcher : Function ) : void
		{
			_deferredProcessWatchers.push( inWatcher );
		}

		public function getTask() : IWorkflowTask
		{
			if( _executionIsDeferred )
				throw new Error(  "Cannot get proxied task while in deferred execution state" );
			return _cachedConditionResult ?
				_isTrueTask : _isFalseTask;
		}

		override public function initialize() : void
		{
			super.initialize();

			if( _isFalseTask )
			{
				_isFalseTask.context = _context;
				_isFalseTask.parent = _parent;
				_isFalseTask.initialize();
			}

			if( _isTrueTask )
			{
				_isTrueTask.context = _context;
				_isTrueTask.parent = _parent;
				_isTrueTask.initialize();
			}
		}

		public function isProcessDeferred() : Boolean
		{
			return _executionIsDeferred;
		}

		override public function prepare() : void
		{
			super.prepare();

			if( _isFalseTask )
				_isFalseTask.prepare();

			if( _isTrueTask )
				_isTrueTask.prepare();
		}

		override public function wakeup() : void
		{
			_executionIsDeferred = false;

			if( _expression )
				_expression.invalidate();
			var result : Object = applyCondition();

			if( result is AsyncExpressionToken )
				setUpAsyncResultHandler( result as AsyncExpressionToken );
			else if( result is Error )
				throw result as Error;
			else if( result is Boolean )
				_cachedConditionResult = result as Boolean;
		}

		private function applyCondition() : Object
		{
			var result : Object;

			if( _expression )
				result = _expression.isAsync && 
					_expression.lastResult !== undefined ?
					_expression.lastResult :
					_expression.evaluate();
			else
				result = _condition;

			if( result is Boolean )
				_cachedConditionResult = result as Boolean;
			return result;
		}

		private function onEvaluationAsyncResult( inEvent : Event ) : void
		{
			IEventDispatcher( inEvent.target ).removeEventListener(
				Event.COMPLETE,
				onEvaluationAsyncResult );
			var result : Object = applyCondition();

			if( result is Boolean )
			{
				_cachedConditionResult = result as Boolean;

				while( _deferredProcessWatchers.length )
					( _deferredProcessWatchers.pop() as Function )( result );
				_executionIsDeferred = false;
			}
			else if( result is AsyncExpressionToken )
			{
				AsyncExpressionToken( result ).addEventListener(
					Event.COMPLETE,
					onEvaluationAsyncResult );
			}
			else if( result is Error )
			{
				_context.fail( 
					this, 
					"Async evaluation failed" + ( result as Error ).getStackTrace() );
				return;
			}
		}

		private function setUpAsyncResultHandler( inToken : AsyncExpressionToken ) : void
		{
			_executionIsDeferred = true;
			inToken.addEventListener(
				Event.COMPLETE,
				onEvaluationAsyncResult );

		}
	}
}
