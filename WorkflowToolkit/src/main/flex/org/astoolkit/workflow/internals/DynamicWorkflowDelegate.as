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
package org.astoolkit.workflow.internals
{

	import org.astoolkit.workflow.api.IWorkflowDelegate;
	import org.astoolkit.workflow.api.IWorkflowTask;

	public class DynamicWorkflowDelegate implements IWorkflowDelegate
	{
		private var _onAbortHandler : Function;

		public function set onAbortHandler( inValue : Function ) : void
		{
			_onAbortHandler = inValue;
		}

		private var _onBeginHandler : Function;

		public function set onBeginHandler(inValue:Function) : void
		{
			_onBeginHandler = inValue;
		}

		private var _onCompleteHandler : Function;

		public function set onCompleteHandler(inValue:Function) : void
		{
			_onCompleteHandler = inValue;
		}

		private var _onFaultHandler : Function;

		public function set onFaultHandler(inValue:Function) : void
		{
			_onFaultHandler = inValue;
		}

		private var _onInitializeHandler : Function;

		public function set onInitializeHandler(inValue:Function) : void
		{
			_onInitializeHandler = inValue;
		}

		private var _onPrepareHandler : Function;

		public function set onPrepareHandler( inValue : Function ) : void
		{
			_onPrepareHandler = inValue;
		}

		private var _onProgressHandler : Function;

		public function set onProgressHandler(inValue:Function) : void
		{
			_onProgressHandler = inValue;
		}

		private var _onResumeHandler : Function;

		public function set onResumeHandler(inValue:Function) : void
		{
			_onResumeHandler = inValue;
		}

		private var _onSuspendHandler : Function;

		public function set onSuspendHandler(inValue:Function) : void
		{
			_onSuspendHandler = inValue;
		}

		public function onAbort(inTask:IWorkflowTask, inMessage:String) : void
		{
			_onAbortHandler( inTask, inMessage );
		}

		public function onBegin(inTask:IWorkflowTask) : void
		{
			_onBeginHandler( inTask );
		}

		public function onComplete(inTask:IWorkflowTask) : void
		{
			_onCompleteHandler( inTask );
		}

		public function onFault(inTask:IWorkflowTask, inMessage:String) : void
		{
			_onFaultHandler( inTask, inMessage );
		}

		public function onInitialize(inTask:IWorkflowTask) : void
		{
			_onInitializeHandler( inTask );
		}

		public function onPrepare(inTask:IWorkflowTask) : void
		{
			_onPrepareHandler( inTask );
		}

		public function onProgress(inTask:IWorkflowTask) : void
		{
			_onProgressHandler( inTask );
		}

		public function onResume(inTask:IWorkflowTask) : void
		{
			_onResumeHandler( inTask );
		}

		public function onSuspend(inTask:IWorkflowTask) : void
		{
			_onSuspendHandler( inTask );
		}
	}
}
