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

	import mx.skins.spark.DefaultButtonSkin;

	import org.astoolkit.commons.io.transform.api.IIODataTransformerClient;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	import org.astoolkit.workflow.api.IPipelineConsumer;
	import org.astoolkit.workflow.api.ISwitchCase;
	import org.astoolkit.workflow.api.ITaskProxy;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.constant.UNDEFINED;

	[DefaultProperty( "cases" )]
	/**
	 * Group for <code>switch</code> style conditional tasks execution.
	 * <p>Children nodes are a vector of ISwitchCase instances, usually a set of
	 * <code>org.astoolkit.workflow.core.Case</code> nodes and one and only one optional
	 * <code>org.astoolkit.workflow.core.Default</code> node.</p>
	 *
	 * Cases are evaluated in the declared order and the first matching case's child elements
	 * will be enabled the Default node's children, if defined, will enabled otherwise.
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>source</code>: a string literal or a binded value to be evaluated against defined cases' values </li>
	 * </ul>
	 * </p>
	 * @example In the following example, a User object is expected as input.<br>
	 * 			Its <code>role</code> property is evaluated and a different message
	 * 			is sent depending on its value.<p>In the second <code>Case</code>
	 * 			the <code>values</code> property with an array of values is used. If any of the
	 * 			listed values matches the enclosed tasks are executed.</p>
	 * <listing version="3.0">
	 * <pre>
	 * &lt;Switch source=&quot;{ User( ENV.$data ).role }&quot;&gt;
	 *     &lt;Case value=&quot;{ UserRole.CUSTOMER }&quot;&gt;
	 *         &lt;msg:SendMessage
	 *             message=&quot;{ new ShowCustomerDashboardMessage() }&quot;
	 *             /&gt;
	 *     &lt;/Case&gt;
	 *     &lt;Case values=&quot;{ [ UserRole.ADMIN, UserRole.SUPER_USER ] }&quot;&gt;
	 *         &lt;msg:SendMessage
	 *             message=&quot;{ new ShowAdminScreenMessage() }&quot;
	 *             /&gt;
	 *     &lt;/Case&gt;
	 *     &lt;Default&gt;
	 *         &lt;msg:SendMessage
	 *             msg=&quot;{ new ShowPublicHomeMessage() }&quot;
	 *             /&gt;
	 *     &lt;/Default&gt;
	 * &lt;/Switch&gt;
	 * </pre>
	 * </listing>
	 *
	 * @see org.astoolkit.workflow.core.Case
	 * @see org.astoolkit.workflow.core.Default
	 * @see org.astoolkit.workflow.api.ISwitchCase
	 */
	public class Switch extends BaseElement implements ITaskProxy, IPipelineConsumer, IIODataTransformerClient
	{
		/**
		 * @private
		 */
		private var _cases : Vector.<ISwitchCase>;

		/**
		 * @private
		 */
		private var _default : Default;

		private var _input : *;

		/**
		 * @private
		 */
		private var _source : *;

		private var _inputFiter : Object;

		/**
		 * @private
		 */
		public function get cases() : Vector.<ISwitchCase>
		{
			return _cases;
		}

		/**
		 * @private
		 */
		public function set cases( inValue : Vector.<ISwitchCase> ) : void
		{
			if( inValue )
			{
				_cases = new Vector.<ISwitchCase>;

				for each( var aCase : ISwitchCase in inValue )
				{
					if( aCase is Default )
					{
						if( _default )
							throw new Error( "There can only be one Default in a Switch" );
						else
							_default = aCase as Default;
					}
					else
						_cases.push( aCase );
				}
			}
		}

		public function set dataTransformerRegistry( inRegistry : IIODataTransformerRegistry ) : void
		{
			// TODO Auto Generated method stub

		}

		public function set input( inData : * ) : void
		{
			_input = inData;
		}


		public function pipelineIsSet() : Boolean
		{
			return _input != UNDEFINED;
		}


		public function set inputFilter( inValue : Object ) : void
		{
			_inputFiter = inValue;
		}

		/**
		 * The value to compare to the children cases
		 */
		public function set source( inValue : * ) : void
		{
			_source = inValue;
		}

		public function getTask() : IWorkflowTask
		{
			if( _cases != null )
			{
				var data : * = resolveInput();
				var result : Boolean;

				if( _cases != null )
				{
					for each( var aCase : ISwitchCase in _cases )
					{
						result = checkCaseValues( aCase, data );

						if( result )
							return aCase.task;
					}

					if( _default != null )
						return _default.task;
				}
			}
			return null;
		}

		/**
		 * @private
		 */
		override public function initialize() : void
		{
			super.initialize();

			if( _cases != null )
			{
				for each( var caze : ISwitchCase in _cases )
				{
					caze.task.liveCycleDelegate = _delegate;
					caze.task.context = _context;
					caze.task.parent = _parent;
					caze.task.initialize();
				}
			}
		}

		/**
		 * @private
		 */
		override public function prepare() : void
		{
			if( _cases != null )
			{
				for each( var caze : ISwitchCase in _cases )
					caze.task.prepare();
			}
		}

		/**
		 * @private
		 */
		private function checkCaseValues( inCase : ISwitchCase, inValue : * ) : Boolean
		{
			for each( var val : * in inCase.values )
			{
				if( val == inValue )
					return true;
			}
			return false;
		}

		private function resolveInput() : *
		{
			return _input;
		}
	}
}
