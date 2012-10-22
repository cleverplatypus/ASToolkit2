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
	import flash.utils.setTimeout;
	import mx.utils.UIDUtil;
	import org.astoolkit.commons.conditional.AsyncExpressionToken;
	import org.astoolkit.commons.conditional.api.IConditionalExpression;
	import org.astoolkit.commons.eval.api.IRuntimeExpressionEvaluator;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.internals.DynamicTaskLiveCycleWatcher;
	import org.astoolkit.workflow.internals.GroupUtil;
	import org.astoolkit.workflow.internals.HeldTaskInfo;
	import org.astoolkit.workflow.internals.WorkflowExpressionResolver;

	[DefaultProperty( "Execute" )]
	/**
	 * Group for conditional execution of tasks.
	 * <p>The default property <code>Execute</code> is a Vector of elements
	 * that are enabled if <code>condition == true</code><br><br>
	 * An <code>&lt;Else&gt;...&lt;/Else&gt;</code> block can also be declared
	 * for <code>condition == false</code>.
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>condition</code>: a <code>Boolean</code> or boolean expression</li>
	 * </ul>
	 * </p>
	 *
	 * @example In the following example, an Employee object is expected as input.<br>
	 * 			If its isPermanent property is set to true, then a (hypotetical) SendMail task is executed.
	 * <listing version="3.0">
	 * <pre>
	 * &lt;If condition=&quot;{ Employee( ENV.$data ).isPermanent }&quot;&gt;
	 *     &lt;net:SendEmail
	 *         content=&quot;Hi {0}.\nYou're invited to the permanent-employees-only party.&quot;
	 *         parameters=&quot;{ [ Employee( ENV.$data ).fullName ] }&quot;
	 *         /&gt;
	 * &lt;/If&gt;
	 * </pre>
	 * </listing>
	 *
	 * @example Same example but with an Else block.
	 * <listing version="3.0">
	 * <pre>
	 * &lt;If condition=&quot;{ Employee( ENV.$data ).isPermanent }&quot;&gt;
	 *     &lt;Execute&gt;
	 *         &lt;net:SendEmail
	 *             content=&quot;Hi {0}.\nYou're invited to the permanent-employees-only party.&quot;
	 *             parameters=&quot;{ [ Employee( ENV.$data ).fullName ] }&quot;
	 *             /&gt;
	 *     &lt;/Execute&gt;
	 *     &lt;Else&gt;
	 *         &lt;net:SendEmail
	 *             content=&quot;Hi {0}.\nYou can stay home that day&quot;
	 *             parameters=&quot;{ [ Employee( ENV.$data ).fullName ] }&quot;
	 *             /&gt;
	 *     &lt;/Else&gt;
	 * &lt;/If&gt;
	 * </pre>
	 * </listing>
	 *
	 * @example The <code>&lt;Execute&gt;...&lt;/Execute&gt;</code> can be always omitted although,
	 * 			when declaring complex If groups, its use makes the syntax a little bit clearer.
	 * <listing version="3.0">
	 * <pre>
	 * &lt;If condition=&quot;{ Employee( ENV.$data ).isPermanent }&quot;&gt;
	 *     &lt;net:SendEmail
	 *         content=&quot;Hi {0}.\nYou're invited to the permanent-employees-only party.&quot;
	 *         parameters=&quot;{ [ Employee( ENV.$data ).fullName ] }&quot;
	 *         /&gt;
	 *     &lt;Else&gt;
	 *         &lt;net:SendEmail
	 *             content=&quot;Hi {0}.\nYou can stay home that day&quot;
	 *             parameters=&quot;{ [ Employee( ENV.$data ).fullName ] }&quot;
	 *             /&gt;
	 *     &lt;/Else&gt;
	 * &lt;/If&gt;
	 * </pre>
	 * </listing>
	 */
	public class If extends Group
	{
		/**
		 * @private
		 */
		private var _condition : Object;

		/**
		 * @private
		 */
		private var _expression : IConditionalExpression;

		/**
		 * @private
		 */
		private var _isFalseGroup : Group;

		/**
		 * @private
		 */
		private var _isTrueGroup : Group;

		/**
		 * @private
		 */
		private var _joinedChildren : Vector.<IWorkflowElement>;

		/**
		 * @private
		 */
		private var _myTasksLUT : Object;

		/**
		 * @private
		 */
		private var _stringExpression : String;

		private var _taskBlocker : HeldTaskInfo;

		/**
		 * (optional) the tasks to enable with <code>condition == false</code>
		 */
		public function set Else( inValue : Vector.<IWorkflowElement> ) : void
		{
			_isFalseGroup = new Group();
			_isFalseGroup.children = inValue;
		}

		/**
		 * the tasks to enable with <code>condition == true</code>
		 */
		public function set Execute( inValue : Vector.<IWorkflowElement> ) : void
		{
			_isTrueGroup = new Group();
			_isTrueGroup.children = inValue;
		}

		/**
		 * @private
		 */
		override public function get children() : Vector.<IWorkflowElement>
		{
			if( _joinedChildren == null )
			{
				_joinedChildren = new Vector.<IWorkflowElement>();

				if( _isTrueGroup )
					_joinedChildren.push( _isTrueGroup );

				if( _isFalseGroup )
					_joinedChildren.push( _isFalseGroup );
			}
			return _joinedChildren;
		}

		/**
		 * the Boolean evaluated for conditional execution.
		 *
		 * @see #Execute
		 * @see #Else
		 */
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

		/**
		 * @private
		 */
		override public function initialize() : void
		{
			super.initialize();

			_myTasksLUT = {};

			if( _stringExpression )
			{
				_expression =
					_context
					.config
					.runtimeExpressionEvalutators
					.getEvaluator( _stringExpression, IConditionalExpression )
					as IConditionalExpression;

				if( _expression )
				{
					if( _expression is IContextAwareElement )
						IContextAwareElement( _expression ).context = _context;
					IRuntimeExpressionEvaluator( _expression ).runtimeExpression = _stringExpression;
				}
				else
				{
					throw new Error( "Runtime expression evaluator " +
						"not found for string " + _stringExpression );
				}

			}

			if( _expression )
				_expression.invalidate();

			for each( var task : IWorkflowTask in GroupUtil.getRuntimeOverridableTasks( children ) )
			{
				_myTasksLUT[ UIDUtil.getUID( task ) ] = UIDUtil.getUID( task );
			}
			var watcher : DynamicTaskLiveCycleWatcher = new DynamicTaskLiveCycleWatcher();
			watcher.beforeTaskBeginWatcher = onBeforeTaskBegin;
			_context.addTaskLiveCycleWatcher( watcher );

			if( _isTrueGroup != null )
			{
				_isTrueGroup.delegate = _delegate;
				_isTrueGroup.context = _context;
				_isTrueGroup.parent = this;
				_isTrueGroup.initialize();
			}

			if( _isFalseGroup != null )
			{
				_isFalseGroup.delegate = _delegate;
				_isFalseGroup.context = _context;
				_isFalseGroup.parent = this;
				_isFalseGroup.initialize();
			}

			if( _expression )
				_expression.resolver = new WorkflowExpressionResolver( _context );
		}

		/**
		 * @private
		 */
		override public function initialized( inDocument : Object, inId : String ) : void
		{
			super.initialized( inDocument, inId );

			if( _isFalseGroup )
				_isFalseGroup.document = inDocument;

			if( _isTrueGroup )
				_isTrueGroup.document = inDocument;
		}

		/**
		 * @private
		 */
		override public function prepare() : void
		{
			if( _isTrueGroup != null )
				_isTrueGroup.prepare();

			if( _isFalseGroup != null )
				_isFalseGroup.prepare();

			if( _expression )
				_expression.clearResult();
		}

		private function applyCondition() : Object
		{
			var result : Object;

			if( _expression )
				result = _expression.async && _expression.lastResult !== undefined ?
					_expression.lastResult :
					_expression.evaluate();
			else
				result = _condition;

			if( result is Boolean )
			{
				if( _isTrueGroup )
					_isTrueGroup.enabled = result;

				if( _isFalseGroup )
					_isFalseGroup.enabled = !result;
			}
			return result;
		}

		/**
		 * @private
		 */
		private function onBeforeTaskBegin( inTask : IWorkflowTask ) : void
		{
			if( _myTasksLUT.hasOwnProperty( UIDUtil.getUID( inTask ) ) )
			{
				var result : Object = applyCondition();

				if( result is AsyncExpressionToken )
				{
					_taskBlocker = inTask.hold();
					setUpAsyncResultHandler( result as AsyncExpressionToken );
				}

				if( result is Error )
				{
					_taskBlocker = inTask.hold();
					setTimeout( function() : void {
						_taskBlocker.release( Error( result ) );
					}, 1 );
				}
			}

		}

		private function onEvaluationAsyncResult( inEvent : Event ) : void
		{
			IEventDispatcher( inEvent.target ).removeEventListener(
				Event.COMPLETE,
				onEvaluationAsyncResult );
			var result : Object = applyCondition();

			if( result is Boolean )
			{
				if( _isTrueGroup )
					_isTrueGroup.enabled = result == true;

				if( _isFalseGroup )
					_isFalseGroup.enabled = result == false;

				_taskBlocker.release();
				_taskBlocker = null;
			}
			else if( result is AsyncExpressionToken )
			{
				AsyncExpressionToken( result ).addEventListener(
					Event.COMPLETE,
					onEvaluationAsyncResult );
			}
			else if( result is Error )
			{
				_taskBlocker.release( result as Error );
			}
		}

		private function setUpAsyncResultHandler( inToken : AsyncExpressionToken ) : void
		{
			inToken.addEventListener(
				Event.COMPLETE,
				onEvaluationAsyncResult );
		}
	}
}
