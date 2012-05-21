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
   import org.astoolkit.workflow.api.*;
   
   import flash.events.Event;
   
   import mx.rpc.Fault;

	public class WorkflowEvent extends Event
	{
		public static const INITIALIZED : String = "initialized";
		public static const STARTED : String = "started";
		public static const DATA_SET : String = "dataSet";
		public static const PREPARED : String = "prepared";
		public static const SUSPENDED : String = "suspended";
		public static const RESUMED : String = "resumed";
	    public static const FAULT : String = "fault";
	    public static const COMPLETED : String = "completed";
		public static const ABORTED : String = "abort";
		public static const PROGRESS : String = "progress";
	
		public static const SUBTASK_INITIALIZED : String = "subtaskInitialize";
		public static const SUBTASK_STARTED : String = "subtaskStarted";
		public static const SUBTASK_DATA_SET : String = "subtaskDataSet";
		public static const SUBTASK_PREPARED : String = "subtaskPrepared";
		public static const SUBTASK_SUSPENDED : String = "subtaskSuspended";
		public static const SUBTASK_RESUMED : String = "subtaskResumed";
		public static const SUBTASK_FAULT : String = "subtaskFault";
		public static const SUBTASK_COMPLETED : String = "subtaskCompleted";
		public static const SUBTASK_ABORTED : String = "subtaskAbort";
		public static const SUBTASK_PROGRESS : String = "subtaskProgress";
		
		private var _data : Object = "";
		
		private var _relatedTask : IWorkflowTask;
		
		private var _context : IWorkflowContext;
		
		public function WorkflowEvent( 
			inType : String, 
			inContext : IWorkflowContext,
			inRelatedTask : IWorkflowTask = null, 
			inData : Object = "" )
	      {
	         super( inType );
	         _data = inData;
			 _relatedTask = inRelatedTask;
			 _context = inContext;
	      }
	            
		public function get relatedTask() : IWorkflowTask
		{
			return _relatedTask;
		}
		
		public function get data() : Object
		{
			return _data;
		}
		
		override public function clone() : Event
		{
			var e : WorkflowEvent = new WorkflowEvent( type, _context, _relatedTask, _data );
			return e;
		}
			
   	}
}