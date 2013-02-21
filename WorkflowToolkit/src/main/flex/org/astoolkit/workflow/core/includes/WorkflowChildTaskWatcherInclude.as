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
import org.astoolkit.workflow.constant.TaskPhase;
import org.astoolkit.workflow.core.ExitStatus;
import org.astoolkit.workflow.core.Workflow;

namespace INTERNAL = "org.astoolkit.workflow.core.do::INTERNAL";

class ChildTaskWatcher implements ITaskLiveCycleWatcher
{
	private var _wf : Workflow;

	public function ChildTaskWatcher( inWorkflow : Workflow )
	{
		_wf = inWorkflow;
	}


	public function get taskWatcherPriority() : int
	{
		return 0;
	}

	public function set taskWatcherPriority( inValue : int ) : void
	{
	}


	public function onTaskPhase( inTask : IWorkflowTask, inPhase : String, inData : Object = null ) : void
	{
		if( inPhase == TaskPhase.PREPARED )
		{
			_wf.INTERNAL::onRootTaskPrepare( inTask );
		}
		else if( inPhase == TaskPhase.RESUMED_DEFERRED_EXECUTION )
		{

		}
		else if( inPhase == TaskPhase.AFTER_BEGIN )
		{
		}
		else if( inPhase == TaskPhase.DEFERRING_EXECUTION )
		{
		}
		else if( inPhase == TaskPhase.COMPLETED )
		{
			_wf.INTERNAL::onRootTaskComplete( inTask );
		}
		else if( inPhase == TaskPhase.BEGUN )
		{
			_wf.INTERNAL::onRootTaskBegin( inTask );
		}
		else if( inPhase == TaskPhase.CONTEXT_BOND )
		{
		}
		else if( inPhase == TaskPhase.BEFORE_BEGIN )
		{
		}
		else if( inPhase == TaskPhase.DATA_SET )
		{
		}
		else if( inPhase == TaskPhase.RESUMED )
		{
			_wf.INTERNAL::onRootTaskResume( inTask );
		}
		else if( inPhase == TaskPhase.PROGRESS )
		{
			_wf.INTERNAL::onRootTaskProgress( inTask );
		}
		else if( inPhase == TaskPhase.SUSPENDED )
		{
			_wf.INTERNAL::onRootTaskSuspend( inTask );
		}
		else if( inPhase == TaskPhase.INITIALISED )
		{
			_wf.INTERNAL::onRootTaskInitialize( inTask );
		}
		else if( inPhase == TaskPhase.FAILED )
		{
			_wf.INTERNAL::onRootTaskFault( inTask, inData as String );
		}
		else if( inPhase == TaskPhase.ABORTED )
		{
			_wf.INTERNAL::onRootTaskAbort( inTask );
		}
		else if( inPhase == TaskPhase.EXIT_STATUS )
		{
		}


	}


}
