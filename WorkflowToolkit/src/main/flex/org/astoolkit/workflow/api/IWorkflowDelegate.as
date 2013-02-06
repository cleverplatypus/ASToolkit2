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

	import org.astoolkit.workflow.core.ExitStatus;

	//TODO: Rename to something more appropriate (e.g. ITaskLiveCycleDelegate)
	//		Hint: could this be merged with ITaskLiveCycleWatcher?
	public interface IWorkflowDelegate
	{
		function onAbort( inTask : IWorkflowTask ) : void;
		function onBegin( inTask : IWorkflowTask ) : void;
		function onComplete( inTask : IWorkflowTask ) : void;
		function onFault( inTask : IWorkflowTask, inMessage : String ) : void;
		function onInitialize( inTask : IWorkflowTask ) : void;
		function onPrepare( inTask : IWorkflowTask ) : void;
		function onProgress( inTask : IWorkflowTask ) : void;
		function onResume( inTask : IWorkflowTask ) : void;
		function onSuspend( inTask : IWorkflowTask ) : void;
	}
}
