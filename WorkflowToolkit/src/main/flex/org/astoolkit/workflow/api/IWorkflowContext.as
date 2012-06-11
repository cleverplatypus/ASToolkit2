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
	import mx.utils.ObjectProxy;
	import org.astoolkit.commons.collection.api.IIteratorFactory;
	import org.astoolkit.workflow.internals.ContextVariablesProvider;
	import org.astoolkit.workflow.internals.SuspendableFunctionRegistry;
	
	[Bindable]
	public interface IWorkflowContext extends IEventDispatcher
	{
		function addTaskLiveCycleWatcher( inValue : ITaskLiveCycleWatcher ) : void;
		function cleanup() : void;
		function get config() : IContextConfig;
		function set config( inValue : IContextConfig ) : void;
		function get data() : Object;
		function set dropIns( inValue : Object ) : void;
		function init() : void;
		function get initialized() : Boolean;
		function get plugIns() : Vector.<IContextPlugIn>;
		function removeTaskLiveCycleWatcher( inValue : ITaskLiveCycleWatcher ) : void;
		function get runningTask() : IWorkflowTask;
		function set runningTask( inTask : IWorkflowTask ) : void;
		function get status() : String;
		function set status( inStatus : String ) : void;
		function get suspendableFunctions() : SuspendableFunctionRegistry;
		function get taskLiveCycleWatchers() : Vector.<ITaskLiveCycleWatcher>;
		function get variables() : ContextVariablesProvider;
		function set variables( inValue : ContextVariablesProvider ) : void;
	}
}
