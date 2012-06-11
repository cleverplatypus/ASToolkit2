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

	/**
	 * Tasks' completion information wrapper.
	 * <p>Upon execution, each task has access to the previously executed task's exit status
	 * via the <code>$.exitStatus</code> context variable</p>
	 *
	 * @example In the following example, the <code>g_optionalTasks</code> group is executed
	 * 			only if the previous task is not canceled by the user.
	 * <listing version="3.0">
	 * <pre>
	 * &lt;io:PromptUserForFileSelection
	 *     message=&quot;Select a file&quot;
	 *     /&gt;
	 * &lt;Group
	 *     id=&quot;g_optionalTasks&quot;
	 *     enabled=&quot;{ $.exitStatus != ExitStatus.USER_CANCELED }&quot;
	 *     &gt;
	 *         &lt;email:AttachFile /&gt;
	 *         &lt;msg:SendMessage
	 *             message=&quot;{new ShowAttachment( $.data ) }&quot;
	 *             /&gt;
	 * &lt;/Group&gt;
	 * </pre>
	 * </listing>
	 */
	public final class ExitStatus
	{
		public static const ABORTED : String = "aborted";

		public static const COMPLETE : String = "complete";

		public static const DEFAULT_STATUS : ExitStatus = new ExitStatus( COMPLETE );

		public static const FAILED : String = "failed";

		public static const TIME_OUT : String = "timeOut";

		public static const USER_CANCELED : String = "userCanceled";

		public function ExitStatus( inCode : String, inMessage : String = null, inData : Object = null, inInterrupted : Boolean = false )
		{
			_code = inCode;
			_message = inMessage;
			_data = inData;
			_interrupted = inInterrupted || _code == FAILED || _code == TIME_OUT || _code == USER_CANCELED;
		}

		private var _code : String;

		private var _data : Object;

		private var _interrupted : Boolean;

		private var _message : String;

		/**
		 * status code
		 */
		public function get code() : String
		{
			return _code;
		}

		/**
		 * (optional) any data related to the status (e.g. an <code>Error</code> that caused a failure)
		 */
		public function get data() : Object
		{
			return _data;
		}

		/**
		 * whether the task didn't complete normally.
		 */
		public function get interrupted() : Boolean
		{
			return _interrupted;
		}

		/**
		 * (optional) human readable information about the status (e.g. an error message)
		 */
		public function get message() : String
		{
			return _message;
		}
	}
}
