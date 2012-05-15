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
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.workflow.core.ExitStatus;
	
	import flash.events.IEventDispatcher;
	
	import mx.core.IFactory;
	import mx.rpc.Fault;
	
	[Event(
		name="started",
		type="org.astoolkit.workflow.core.WorkflowEvent")]
	[Event(
		name="initialize",
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
	
	public interface IWorkflowTask 
		extends IWorkflowElement, IEventDispatcher
	{
		

		
		//=================== DATA PIPELINE =============================
		
		function set ignoreOutput( inIgnoreOutput: Boolean ) : void;
		
		function get output() : *;
		
		function set timeout( inMillisecs : int ) : void;
		
		function set input( inData : * ) : void;
		
		/**
		 * a filter for this task's pipeline data.<br><br>
		 */
		function set inputFilter( inValue : Object ) : void;
		function get inputFilter() : Object;
		
		function get filteredPipelineData() : Object;

		function set inlet( inInlet : Object ) : void;
		function get inlet() : Object;
		
		function set outlet( inInlet : Object ) : void;
		function get outlet() : Object;
		
		function get invalidPipelinePolicy() : String;
		function set invalidPipelinePolicy( inValue : String ) : void;
		
		/**
		 * the message to use in case of failure.
		 * 
		 * <p>This is the text that is either sent as <code>WorkflowEvent</code>
		 * when <code>failurePolicy="abort"</code> or logged when
		 * <code>failurePolicy="log-[LEVEL]"</code>.</p>
		 * 
		*/ 
		function set failureMessage( inValue : String ) : void;
		function get failureMessage() : String;

		//================================================================
		
		function get status() : String;
				
		/**
		 * Whether to run this task is executing 
		 * either asyncronously or synchronously.
		 */ 
		function get running() : Boolean
		
		/**
		 * instructs the wrapping worfklow on what to do
		 * if this task fails.
		 * Acceptable values are: ignore, abort, warn
		 * ignore: continues flow
		 * abort: the parent workflow fails too
		 * warn: continues flow but logs error 
		 */
		function get failurePolicy() : String;
		function set failurePolicy( inPolicy : String ) : void;
		
		
		/**
		 * read only. returns the 0 to 1 progress of this task.
		 * A value of -1 means that this task won't provide progress information.
		 */
		function get currentProgress() : Number;
		function set currentProgress( inValue : Number ) : void;

		/**
		 * the number of milliseconds the wrapping workflow will wait
		 * before calling begin().
		 * Notice that prepare() will be called before this delay. 
		 */
		function get delay():int;
		function set delay( inDelay : int ) : void;

		
		/**
		 * this is the method a new task will always implement.
		 * It's where the task's async operations are fired.
		 * Once the task is complete it should call its delegate's 
		 * onComplete() or onFault(...) asyncronously, that is, not 
		 * in the begin() call stack.
		 */
		function begin() : void;
			
				
		/**
		 * called by user defined code or by aborted wrapping workflow.
		 * implementations should take care of cancelling any pending async 
		 * operations or event listeners
		 */  
		function abort() : void;
		
		/**
		 * stops the whole workflow at this task until resume is called.
		 */
		function suspend() : void;
		
		/**
		 * resumes the whole workflow from the point where
		 * suspend() was called. Not necessarily this task.
		 * It might be any root workflow's children task.
		 */
		function resume() : void;

		
		function set exitStatus( inStatus : ExitStatus ) : void;
		function get exitStatus() : ExitStatus;
		
		/**
		 * The current thread number.
		 */ 
		function get currentThread() : uint
			

	}
}