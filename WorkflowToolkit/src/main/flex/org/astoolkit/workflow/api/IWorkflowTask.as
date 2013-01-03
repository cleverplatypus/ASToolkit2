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
	import mx.rpc.Fault;
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerClient;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	import org.astoolkit.commons.mapping.DataMap;
	import org.astoolkit.workflow.core.ExitStatus;
	import org.astoolkit.workflow.internals.HeldTaskInfo;

	[Event(
		name = "started",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "initialize",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "warning",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "fault",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "completed",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "progress",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	[Event(
		name = "prepare",
		type = "org.astoolkit.workflow.core.WorkflowEvent" )]
	public interface IWorkflowTask extends IWorkflowElement,
		IEventDispatcher,
		IIODataTransformerClient,
		IPipelineConsumer,
		IDeferrableProcess
	{

		//TODO: replace with IExecutionDeferrable functionality
		function get blocker() : HeldTaskInfo;
		/**
		 * read only. returns the 0 to 1 progress of this task.
		 * A value of -1 means that this task won't provide progress information.
		 */
		function get currentProgress() : Number;
		function set currentProgress( inValue : Number ) : void;
		/**
		 * The current thread number.
		 */
		function get currentThread() : uint;
		/**
		 * the number of milliseconds the wrapping workflow will wait
		 * before calling begin().
		 * Notice that prepare() will be called before this delay.
		 */
		function get delay() : int;
		function set delay( inDelay : int ) : void;
		function get exitStatus() : ExitStatus;
		/**
		 * set this before calling <code>complete()</code> or <code>fail()</code>
		 * if you want to set a custom exit status.
		 */
		function set exitStatus( inStatus : ExitStatus ) : void;
		function get failureMessage() : String;
		/**
		 * the message to use in case of failure.
		 *
		 * <p>This is the text that is either sent as <code>WorkflowEvent</code>
		 * when <code>failurePolicy="abort"</code> or logged when
		 * <code>failurePolicy="log-<i>[LEVEL]</i>"</code>.</p>
		 *
		 * <p>Placeholders {<i>n</i>} can be used to include context
		 * information in the message</p>
		 * <ul>
		 * <li>{0} the task's description</li>
		 * <li>{1} the Error message if any</li>
		 * <li>{2} the Error stackTrace if any</li>
		 * <li>{3} the pipelineData dump</li>
		 * </ul>
		 * <p>The implementation should provide a default message.</p>
		 *
		 * @example Aborting with custom message
		 * <listing>
		 * &lt;ProcessUser
		 *		failurePolicy="abort"
		 * 		failureMessage="Cannot process user: {3} for error '{1}'"
		 * 		/&gt;
		 * </listing>
		 * The above task would dispatch a <code>WorkflowEvent</code>
		 * containing a message like:
		 * <listing>
		 * Cannot process user:
		 *
		 * (com.myapp.model.User)#0
		 *		username = "dracula"
		 * 		firstName = "Bram"
		 * 		lastName = "Stoker"
		 * 		email = (Null)
		 *
		 * for error: 'Error #1009: Cannot access a property or method of a null object reference'
		 * </listing>
		 */
		function set failureMessage( inValue : String ) : void;
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
		function get filteredInput() : Object;
		function get forceAsync() : Boolean;

		function set forceAsync( inValue : Boolean ) : void;
		//=================== DATA PIPELINE =============================
		function get ignoreOutput() : Boolean;
		function set ignoreOutput( inIgnoreOutput : Boolean ) : void;
		function get inlet() : Object;
		function set inlet( inInlet : Object ) : void;
		function get inputFilter() : Object;
		function get invalidPipelinePolicy() : String;
		function set invalidPipelinePolicy( inValue : String ) : void;
		function get outlet() : Object;
		function set outlet( inInlet : Object ) : void;
		function get output() : *;
		function get outputFilter() : Object;
		function set outputFilter( inValue : Object ) : void;

		[Inspectable( enumeration = "auto", defaultValue = "auto" )]
		/**
		 * an arbitrary string used by the task to decide what to output.
		 * Typically, a task implementation would implement/override this
		 * setter to provide a custom [Inspectable] annotation
		 * with the enumeration of possible values.
		 * <p>The default value is "auto"</p>
		 */
		function set outputKind( inValue : String ) : void;
		/**
		 * Whether to run this task is executing
		 * either asyncronously or synchronously.
		 */
		function get running() : Boolean
		//================================================================
		function get status() : String;

		function set taskParametersMapping( inValue : Object ) : void;
		function set timeout( inMillisecs : int ) : void;

		/**
		 * called by user defined code or by aborted wrapping workflow.
		 */
		function abort() : void;
		/**
		 * this is the method a task will always implement.
		 * It's where the task's async operations are fired.
		 * Once the task is complete it should call its delegate's
		 * onComplete() or onFault(...) asyncronously, that is, not
		 * in the begin() call stack.
		 */
		function begin() : void;

		function hold() : HeldTaskInfo;
		/**
		 * resumes the whole workflow from the point where
		 * suspend() was called. Not necessarily this task.
		 * It might be any root workflow's children task.
		 */
		function resume() : void;
		/**
		 * stops the whole workflow at this task until resume is called.
		 */
		function suspend() : void;
	}
}
