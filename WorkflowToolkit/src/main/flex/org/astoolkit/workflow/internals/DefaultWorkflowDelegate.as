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
	import org.astoolkit.workflow.core.Workflow;
	import org.astoolkit.workflow.ns.workflow_internal;
	use namespace workflow_internal;
	
	public class DefaultWorkflowDelegate implements IWorkflowDelegate
	{
		public function DefaultWorkflowDelegate( inWorkflow : Workflow )
		{
			_workflow = inWorkflow;
		}
		
		private var _workflow : Workflow;
		
		public function onAbort( inTask : IWorkflowTask, inMessage : String ) : void
		{
			_workflow.workflow_internal::onSubtaskAbort( inTask, inMessage );
		}
		
		public function onBegin( inTask : IWorkflowTask ) : void
		{
			_workflow.workflow_internal::onSubtaskBegin( inTask );
		}
		
		public function onComplete( inTask : IWorkflowTask ) : void
		{
			_workflow.workflow_internal::onSubtaskCompleted( inTask );
		}
		
		public function onFault( inTask : IWorkflowTask, inMessage : String ) : void
		{
			_workflow.workflow_internal::onSubtaskFault( inTask, inMessage );
		}
		
		public function onInitialize( inTask : IWorkflowTask ) : void
		{
			_workflow.workflow_internal::onSubtaskInitialized( inTask );
		}
		
		public function onPrepare( inTask : IWorkflowTask ) : void
		{
			_workflow.workflow_internal::onSubtaskPrepared( inTask );
		}
		
		public function onProgress( inTask : IWorkflowTask ) : void
		{
			_workflow.workflow_internal::onSubtaskProgress( inTask );
		}
		
		public function onResume( inTask : IWorkflowTask ) : void
		{
			_workflow.workflow_internal::onSubtaskResumed( inTask );
		}
		
		public function onSuspend( inTask : IWorkflowTask ) : void
		{
			_workflow.workflow_internal::onSubtaskSuspended( inTask );
		}
	}
}
