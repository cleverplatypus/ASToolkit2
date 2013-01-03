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

	import org.astoolkit.workflow.api.IElementsGroup;
	import org.astoolkit.workflow.api.ISwitchCase;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.internals.GroupUtil;

	[DefaultProperty( "task" )]
	/**
	 * A group of elements to enable if <code>value</code> or one of <code>values</code>
	 * matches the parent <code>Switch</code>'s <code>source</code>
	 *
	 * @see org.astoolkit.workflow.core.Switch
	 */
	public class Case extends BaseElement implements ISwitchCase
	{

		private var _task : IWorkflowTask

		private var _value:*;

		private var _values : Array;

		public function get task() : IWorkflowTask
		{
			return null;
		}

		public function get value() : *
		{
			return _value;
		}

		/**
		 * the value to compare to the wrapping <code>Switch</code> group.
		 */
		public function set value( inValue : * ) : void
		{
			_values = [ inValue ];
		}

		public function get values() : Array
		{
			return _values;
		}

		public function set values( inValue : Array ) : void
		{
			_values = inValue;
		}

		public function getTask() : IWorkflowTask
		{
			return _task;
		}
	}
}
