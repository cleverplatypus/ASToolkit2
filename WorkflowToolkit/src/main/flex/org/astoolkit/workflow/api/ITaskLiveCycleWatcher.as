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

	public interface ITaskLiveCycleWatcher
	{
		function get taskWatcherPriority() : int;
		function set taskWatcherPriority( inValue : int ) : void;

		function onTaskPhase( inTask : IWorkflowTask, inPhase : String, inData : * = undefined ) : void;

	}
}
