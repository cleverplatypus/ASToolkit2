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
	import org.astoolkit.commons.factory.api.IPooledFactory;
	import org.astoolkit.commons.factory.api.IPooledFactoryDelegate;
	import org.astoolkit.commons.io.transform.api.IIODataSourceResolverDelegate;
	import org.astoolkit.workflow.internals.ContextVariablesProvider;
	import org.astoolkit.workflow.internals.SuspendableFunctionRegistry;

	[Bindable]
	/**
	 * Contract for a Workflow context object.
	 * A context object is obtained (usually created) through
	 * a <code>mx.core.IFactory</code> every time a workflow is run.
	 * This object is then initialized and made available to the workflow
	 * and its tasks. Contexts can be configured with plug-ins and provide access
	 * to several WorkflowToolkit features:
	 * <ul>
	 * 	<li>Task live-cycle watchers</li>
	 * 	<li>Pooled factories</li>
	 * 	<li>A data transformers registry</li>
	 * 	<li>Class factories mapped by qualified class names patterns</li>
	 * 	<li>Context variables</li>
	 * 	<li>Iterators</li>
	 * </ul>
	 *
	 * Extending IObjectConfigurer, context objects can
	 * inject available resouces to the passed objects based on
	 * the latters' recognized implemented interfaces (e.g. IContextAwareElement ),
	 * metadata, and other plug-in defined criteria.
	 */
	public interface IWorkflowContext extends IEventDispatcher, IObjectConfigurer
	{
		function get config() : IContextConfig;
		function set config( inValue : IContextConfig ) : void;

		//function get data() : Object;
		function get dataSourceResolverDelegate() : IIODataSourceResolverDelegate;

		function set dropIns( inValue : Object ) : void;
		function get initialized() : Boolean;
		function get owner() : IWorkflow;
		function get plugIns() : Vector.<IContextPlugIn>;
		function get runningTask() : IWorkflowTask;
		function set runningTask( inTask : IWorkflowTask ) : void;
		function get status() : String;
		function set status( inStatus : String ) : void;
		function get suspendableFunctions() : SuspendableFunctionRegistry;
		function get taskLiveCycleWatchers() : Vector.<ITaskLiveCycleWatcher>;
		function get variables() : ContextVariablesProvider;
		function set variables( inValue : ContextVariablesProvider ) : void;

		/**
		 * register the passed implementation of ITaskLiveCycleWatcher
		 */
		function addTaskLiveCycleWatcher( inValue : ITaskLiveCycleWatcher, inGroupScope : ITasksFlow = null ) : void;

		/**
		 * called just before the owning workflow calls its cleanup()
		 */
		function cleanup() : void;
		function fail( inSource : Object, inMessage : String ) : void;
		function getPooledFactory( 
		inClass : Class, 
			inDelegate : IPooledFactoryDelegate = null ) : IPooledFactory;
		function init( inOwner : IWorkflow ) : void;

		/**
		 * unregister the passed implementation of ITaskLiveCycleWatcher
		 */
		function removeTaskLiveCycleWatcher( inValue : ITaskLiveCycleWatcher ) : void;
	}
}
