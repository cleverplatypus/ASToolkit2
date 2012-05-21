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
	import mx.core.IFactory;
	
	import org.astoolkit.commons.collection.api.IRepeater;
	import org.astoolkit.workflow.core.Insert;
	
	[Event(
        name="started",
        type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
        name="warning",
        type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
        name="fault",
        type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
        name="completed",
        type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
        name="progress",
        type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
        name="prepare",
        type="org.astoolkit.workflow.core.WorkflowEvent")]

	[Bindable]
	public interface IWorkflow extends IWorkflowTask, IRepeater, IElementsGroup
	{
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
		function run( inTaskInput : * = undefined ) : *;
		
		function get contextFactory() : IFactory;
		function set contextFactory( inFactory : IFactory ) : void;
		
		function get flow() : String;
		function set flow( inFlow : String ) : void;

		[Inspectable(defaultValue="false", type="String", enumeration="true,false,data")]
		/**
		 * determines whether to repeat execution of children tasks.
		 * <p>if set to "loop" the workflow will cycle indefintely through its children</p>
		 * <p>if set to "data" the workflow will cycle through its children
		 * once for every element of its <code>dataProvider</code>.</p>
		 * <p>Notice that if <code>dataProvider</code> is not set, the workflow
		 * will try to use the data coming in the pipeline as data provider.</p>
		 * <p>Setting <code>iterate</code> to <code>null</code> during workflow execution
		 * will make the workflow complete after its last child.</p>
		 * 
		 */
		function get iterate() : String;
		function set iterate( inIterate: String ) : void;
		
		function get feed() : String;
		function set feed( inPolicy: String ) : void;
	}
}