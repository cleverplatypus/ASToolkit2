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
package org.astoolkit.workflow.task.pipeline
{
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Outputs whatever passed as input after transformations and input filtering
	 * <p>
	 * <b>Any Input</b>
	 * <ul>
	 * <li>INPUT_DESCRIPTION</li>
	 * </ul>
	 * </p>
	 * <p>
	 * <b>Output</b>
	 * <ul>
	 * <li>Any input data after transformations and filtering</li>
	 * </ul>
	 * </p>
	 * @example Using SetPipeline to transform pipeline data
	 * <listing version="3.0">
	 * &lt;!-- we assume input will be a File object --&gt;
	 * &lt;SetPipeline
	 *     inputFilter=&quot;url&quot;
	 *     /&gt;
	 * &lt;!-- the pipeline now contains the File's url string --&gt;
	 * </listing>
	 */
	public class SetPipeline extends BaseTask
	{
		public static const TASKDESCRIPTOR : XML = <taskdescriptor version="1.0" xmlns="http//www.astoolkit.org/ns/taskdescriptor"></taskdescriptor>;

		public var value : *;

		override public function begin() : void
		{
			super.begin();
			complete( value !== undefined ? value : filteredInput );
		}
	}
}
