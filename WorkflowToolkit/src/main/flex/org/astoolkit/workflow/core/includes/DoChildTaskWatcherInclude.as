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
import org.astoolkit.workflow.api.*;
import org.astoolkit.workflow.core.Do;
import org.astoolkit.workflow.core.ExitStatus;

namespace INTERNAL = "org.astoolkit.workflow.core.do::INTERNAL";

[ExcludeClass]
class ChildTaskWatcher implements ITaskLiveCycleWatcher
{
	private var _group : Do;

	public function ChildTaskWatcher( inGroup : Do )
	{
		_group  = inGroup;
	}

	public function afterTaskBegin( inTask : IWorkflowTask ) : void
	{
	}

	public function afterTaskDataSet( inTask : IWorkflowTask ) : void
	{
	}

	public function beforeTaskBegin( inTask : IWorkflowTask ) : void
	{
	}

	public function onBeforeContextUnbond( inTask : IWorkflowElement ) : void
	{
	}

	public function onContextBond( inElement : IWorkflowElement ) : void
	{
	}

	public function onDeferredTaskResume( inTask : IWorkflowTask ) : void
	{
	}

	public function onTaskAbort( inTask : IWorkflowTask ) : void
	{
		_group.INTERNAL::onSubtaskAbort( inTask );
	}

	public function onTaskBegin( inTask : IWorkflowTask ) : void
	{
		_group.INTERNAL::onSubtaskBegin( inTask );
	}

	public function onTaskComplete( inTask : IWorkflowTask ) : void
	{
		_group.INTERNAL::onSubtaskCompleted( inTask );
	}

	public function onTaskDeferExecution( inTask : IWorkflowTask ) : void
	{
	}

	public function onTaskExitStatus( inTask : IWorkflowTask, inStatus : ExitStatus ) : void
	{
	}

	public function onTaskFail( inTask : IWorkflowTask, inMessage : String ) : void
	{
		_group.INTERNAL::onSubtaskFault( inTask, inMessage );
	}

	public function onTaskInitialize( inTask : IWorkflowTask ) : void
	{
		_group.INTERNAL::onSubtaskInitialized( inTask );
	}

	public function onTaskPrepare( inTask : IWorkflowTask ) : void
	{
		_group.INTERNAL::onSubtaskPrepared( inTask );
	}

	public function onTaskSuspend(inTask:IWorkflowTask ) : void
	{
		_group.INTERNAL::onSubtaskSuspended( inTask );
	}

	public function onWorkflowCheckingNextTask( inWorkflow : ITasksGroup, inPipelineData:Object) : void
	{
	}

	public function get taskWatcherPriority() : int
	{
		return 0;
	}

	public function set taskWatcherPriority( inValue : int ) : void
	{
	}

	public function onTaskProgress(inTask:IWorkflowTask) : void
	{
		_group.INTERNAL::onSubtaskProgress( inTask );
	}

	public function onTaskResume(inTask:IWorkflowTask) : void
	{
		_group.INTERNAL::onSubtaskResumed( inTask );
	}

}
