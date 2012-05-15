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
	import flash.utils.flash_proxy;
	
	import mx.utils.ObjectProxy;
	import mx.utils.UIDUtil;
	
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.core.ExitStatus;
	
	use namespace flash_proxy;
	[Bindable]
	public dynamic class ContextVariablesProvider 
		extends ObjectProxy 
		implements ITaskLiveCycleWatcher
	{
		
		
		/**
		 * @private
		 */
		private var _namespaces : Object;
		/**
		 * @private
		 */
		private var _runningTask : IWorkflowTask;
		/**
		 * @private
		 */
		private var _local : Object;
		/**
		 * @private
		 */
		private var _runningWorkflow : IWorkflow;
		/**
		 * @private
		 */
		private var _runningWorkflowPipelineData : Object;
		
		/**
		 * @private
		 */
		public function ContextVariablesProvider() : void
		{
			_namespaces = {};
			_local = {};
		}

		/**
		 * the currently running task
		 */
		public function get self() : IWorkflowTask
		{
			return _runningTask;
		}
		
		public function set self( inValue : IWorkflowTask ) : void
		{
			throw new Error( "\"self\" is a read-only reserved word.")

		}
		/**
		 * the previously executed task's exit status
		 */
		public function get exitStatus() : ExitStatus
		{
			return getProperty( new QName( null, "exitStatus" ) );
		}
		
		public function set exitStatus( inValue : ExitStatus ) : void
		{
			throw new Error( "\"exitStatus\" is a read-only reserved word.")
		}
		
		/**
		 * the current filtered pipeline data
		 */
		public function get data() : Object
		{
			if( !_runningTask )
				return null;
			return _runningTask.filteredPipelineData;
		}
		
		public function set data( inValue : Object ) : void
		{
			throw new Error( "\"data\" is a read-only reserved word.")
		}
		
		/**
		 * the current non-filtered pipeline data
		 */
		public function get rawData() : Object
		{
			if( !_runningWorkflow )
				return null;
			return _runningWorkflowPipelineData;
		}
		
		public function set rawData( inValue : Object ) : void
		{
			throw new Error( "\"rawData\" is a read-only reserved word.")
		}
		
		/**
		 * the parent group
		 */
		public function get parent() : IElementsGroup
		{
			if( !_runningTask )
				return null;
			return _runningTask.parent;
		}
		
		public function set parent( inValue : IElementsGroup ) : void
		{
			throw new Error( "\"parent\" is a read-only reserved word.")
		}
		
		/**
		 * the first <code>IWorkflow</code> found in the parents chain
		 */
		public function get parentWorkflow() : IWorkflow
		{
			if( !_runningTask )
				return null;
			return GroupUtil.getParentWorkflow( _runningTask );
		}
		
		public function set parentWorkflow( inValue : IWorkflow ) : void
		{
			throw new Error( "\"parentWorkflow\" is a read-only reserved word.")
		}
		
		/**
		 * the current index of the parent <code>IWorkflow</code>'s IIterator, if any; -1 otherwise.
		 */
		public function get i() : int
		{
			if( _runningTask )
			{
				var pi : IRepeater = GroupUtil.getParentRepeater( _runningTask );
				if( pi && pi.iterator )
					return pi.iterator.currentIndex();
			}
			return -1;
		}
		
		public function set i( inValue : int ) : void
		{
			throw new Error( "\"i\" is a read-only reserved word.")
		}
		
		
		/**
		 * the current data of the parent <code>IWorkflow</code>'s IIterator, if any; undefined otherwise.
		 */
		public function get currentData() : Object
		{
			if( !_runningTask )
				return undefined;
			var p : IRepeater = GroupUtil.getParentRepeater( _runningTask );
			if( p && p.iterator )
				return p.iterator.current();
			return undefined;
		}
		
		public function set currentData( inValue : Object ) : void
		{
			throw new Error( "\"currentData\" is a read-only reserved word.")
		}
		
		/**
		 * @private
		 */
		override flash_proxy function setProperty( inName:*, inValue:*):void
		{
			var parent : IWorkflow = GroupUtil.getParentWorkflow( _runningTask );
			if( !parent )
				parent = _runningTask as IWorkflow;
			var n : String = UIDUtil.getUID( parent );
			if( !_namespaces.hasOwnProperty( n ) )
				_namespaces[ n ] = {};
			_namespaces[ n ][ inName.localName ] = inValue;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function getProperty( inName : * ) : *
		{
			var parent : IElementsGroup = GroupUtil.getParentWorkflow( _runningTask );
			var n : String;
			do
			{	
				n  = UIDUtil.getUID( parent );
				if( _namespaces.hasOwnProperty( n ) && 
					_namespaces[ n ].hasOwnProperty( inName.localName ) )
				{
					return _namespaces[ n ][ inName.localName ];
				}
				parent = GroupUtil.getParentWorkflow( parent );
			} while( parent != null );
			return undefined;
		}
		
		
		/**
		 * @private
		 */
		public function afterTaskBegin(inTask:IWorkflowTask):void
		{
			// TODO Auto Generated method stub
			
		}
		
		/**
		 * @private
		 */
		public function afterTaskDataSet(inTask:IWorkflowTask):void
		{
			// TODO Auto Generated method stub
			
		}
		
		/**
		 * @private
		 */
		public function beforeTaskBegin(inTask:IWorkflowTask):void
		{
			if( !( inTask is IWorkflow ) )
			{
				_runningTask = inTask;
			}
		}
		
		/**
		 * @private
		 */
		public function onTaskAbort(inTask:IWorkflowTask):void
		{
			// TODO Auto Generated method stub
		}
		
		/**
		 * @private
		 */
		public function onTaskBegin(inTask:IWorkflowTask):void
		{
			// TODO Auto Generated method stub
		}
		
		/**
		 * @private
		 */
		public function onTaskComplete(inTask:IWorkflowTask):void
		{
			if( inTask is IWorkflow && _namespaces.hasOwnProperty( UIDUtil.getUID( inTask ) ) )
				delete _namespaces[ UIDUtil.getUID( inTask ) ];
		}
		
		/**
		 * @private
		 */
		public function onTaskFail(inTask:IWorkflowTask):void
		{
			if( inTask is IWorkflow && _namespaces.hasOwnProperty( UIDUtil.getUID( inTask ) ) )
				delete _namespaces[ UIDUtil.getUID( inTask ) ];
		}
		
		/**
		 * @private
		 */
		public function onTaskInitialize(inTask:IWorkflowTask):void
		{
			// TODO Auto Generated method stub
		}
		
		/**
		 * @private
		 */
		public function onTaskSuspend(inTask:IWorkflowTask):void
		{
			// TODO Auto Generated method stub
		}
		
		/**
		 * @private
		 */
		public function onTaskExitStatus( inTask : IWorkflowTask, inStatus : ExitStatus):void
		{
			var parent : IWorkflow = GroupUtil.getParentWorkflow( _runningTask );
			if( !parent )
				parent = _runningTask as IWorkflow;
			var n : String = UIDUtil.getUID( parent );
			if( !_namespaces.hasOwnProperty( n ) )
				_namespaces[ n ] = {};
			_namespaces[ n ][ "exitStatus" ] = inStatus;
		}
		
		/**
		 * @private
		 */
		public function onWorkflowCheckingNextTask( 
			inWorkflow : IWorkflow, 
			inPipelineData : Object ) : void
		{
			_runningWorkflow = inWorkflow;
			_runningWorkflowPipelineData = inPipelineData;
		}
		
		/**
		 * @private
		 */
		public function onContextBound( inTask : IWorkflowTask ) : void
		{
			
		}
	}
}