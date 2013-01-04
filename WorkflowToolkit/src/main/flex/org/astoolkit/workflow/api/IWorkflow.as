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
package org.astoolkit.workflow.api
{

	import flash.events.IEventDispatcher;
	import mx.core.IFactory;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerClient;
	import org.astoolkit.commons.utils.IChildrenAwareDocument;

	public interface IWorkflow extends IEventDispatcher, IChildrenAwareDocument, IIODataTransformerClient
	{
		function get context() : IWorkflowContext;
		function set contextFactory( inValue : IFactory ) : void;
		function get rootTask() : IWorkflowTask;
		function set rootTask( inValue : IWorkflowTask ) : void;

		/**
		 * Execution entry point for the root <code>IWorkflow</code>.
		 * <p>The optional parameter sets the pipeline data.</p>
		 * <p>If the workflow completes synchronously, this method
		 * returns the workflow's output, <code>undefined</code> otherwise.</p>
		 *
		 * @param myInputData optional data for the pipeline
		 *
		 * @return the workflow's output if the latter completes synchronously, <code>undefined</code> otherwise
		 *
		 * @example Executing a sync workflow.
		 * 			<p>In this example we're running a workflow that
		 * 			does some filtering on the input data andcompletes synchronously</p>
		 *
		 * <listing version="3.0">
		 * public function runFilterDataWorkflow() : void
		 * {
		 *     var output : Array = filterDataWorkflow.run( myInputData );
		 * }
		 * </listing>
		 */
		function run( inData : * = undefined ) : *;
	}
}
