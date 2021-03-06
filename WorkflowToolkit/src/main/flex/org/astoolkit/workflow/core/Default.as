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

	import org.astoolkit.workflow.api.ISwitchCase;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.api.IWorkflowTask;

	[DefaultProperty( "task" )]
	/**
	 * The <code>default</code> case block for a <code>Switch</code> group.
	 * <p>Its children are enabled if none of the <code>Case</code> groups are.</p>
	 */
	public class Default extends BaseElement implements ISwitchCase
	{
		private var _task : IWorkflowTask;

		public function get task() : IWorkflowTask
		{
			return _task;
		}

		public function set task( inValue : IWorkflowTask ) : void
		{
			_task = inValue;
		}

		public function get value() : *
		{
			return undefined;
		}

		public function get values() : Array
		{
			return null;
		}

		public function getTask() : IWorkflowTask
		{
			return _task;
		}
	}
}
