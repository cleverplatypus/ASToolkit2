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
	
	import org.astoolkit.commons.collection.api.IRepeater;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.core.ExitStatus;
	
	use namespace flash_proxy;
	[Bindable]
	/**
	 * The workflow's context variables provider.
	 * <p>This class gives access to pre-defined variables
	 * as well as user defined ones.</p>
	 * <p>User defined variables are scoped to the wrapping
	 * <code>IWorkflow</code> and children. To set a variable
	 * with wide scope, declare it (e.g. with <code>&lt;SetProperty /&gt;</code> or
	 * in a task's outlet) in an outer workflow and then use it in inner ones.</p>
	 * 
	 * @see org.astoolkit.workflow.IWorkflowTask#$
	 */ 
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
			return _runningTask.filteredInput;
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
		 * <p>It can be used with a trailing index number (0-<em>n</em>) to access outer
		 * iterator indexes.</p>
		 * <p>i and i0 are equivalent</p>.
		 * 
		 * @example Accessing grand-parent's iterator index.
		 * 			<p>In the first cycle the <code>Trace</code>
		 * 			tasks will output "0","0", "0", in the second
		 * 			"1","1","0" and so on.</p>
		 * <listing version="3.0">
		 * &lt;Workflow
		 *     dataProvider=&quot;{ [ 10, 20, 30, 40 ] }&quot;
		 *     &gt;
		 *     &lt;Workflow
		 *         dataProvider=&quot;{ [ 'a', 'b', 'c', 'd' ] }&quot;
		 *         &gt;
		 *         &lt;log:Trace
		 *             text=&quot;{ $.i }&quot;
		 *             /&gt;
		 *         &lt;log:Trace
		 *             text=&quot;{ $.i0 }&quot;
		 *             /&gt;
		 *         &lt;log:Trace
		 *             text=&quot;{ $.i1 }&quot;
		 *             /&gt;
		 *     &lt;/Workflow&gt;
		 * &lt;/Workflow&gt;
		 * </listing>
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
		
		/**
		 * @private
		 * 
		 * returns the current index of the ancestor <code>IWorkflow</code>'s IIterator, 
		 * <code>inParentCount</code> levels up, if any; -1 otherwise.
		 */
		private function getAncestorI( inParentCount : int = 0 ) : int
		{
			if( _runningTask )
			{
				var pi : IRepeater = GroupUtil.getParentRepeater( _runningTask, inParentCount );
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
		 * @private
		 * 
		 * returns the current data of the ancestor <code>IWorkflow</code>'s IIterator, 
		 * <code>inParentCount</code> levels up, if any; <code>undefined</code> otherwise.
		 */
		private function getAncestorCurrentData( inParentCount : int = 0 ) : Object
		{
			if( !_runningTask )
				return undefined;
			var p : IRepeater = GroupUtil.getParentRepeater( _runningTask, inParentCount );
			if( p && p.iterator )
				return p.iterator.current();
			return undefined;
		}
		
		
		/**
		 * the current data of the parent <code>IWorkflow</code>'s IIterator, if any; undefined otherwise.
		 * <p>It can be used with a trailing index number (0-<em>n</em>) to access outer
		 * iterator current data.</p>
		 * <p>currentData and currentData0 are equivalent</p>.
		 * 
		 * @example Accessing grand-parent's iterator currentData.
		 * 			<p>In the first cycle the <code>Trace</code>
		 * 			tasks will output "a","a", "10", in the second
		 * 			"b","b","10" and so on.</p>
		 * <listing version="3.0">
		 * &lt;Workflow
		 *     dataProvider=&quot;{ [ 10, 20, 30, 40 ] }&quot;
		 *     &gt;
		 *     &lt;Workflow
		 *         dataProvider=&quot;{ [ 'a', 'b', 'c', 'd' ] }&quot;
		 *         &gt;
		 *         &lt;log:Trace
		 *             text=&quot;{ $.i }&quot;
		 *             /&gt;
		 *         &lt;log:Trace
		 *             text=&quot;{ $.i0 }&quot;
		 *             /&gt;
		 *         &lt;log:Trace
		 *             text=&quot;{ $.i1 }&quot;
		 *             /&gt;
		 *     &lt;/Workflow&gt;
		 * &lt;/Workflow&gt;
		 * </listing>
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
			var n : String = UIDUtil.getUID( parent );
			if( !parent )
				parent = _runningTask as IWorkflow;
			if( !inName.localName.match( /^_.*/ ) )
			{
				for( var ln : String in _namespaces )
				{
					if( _namespaces[ ln ].hasOwnProperty( inName.localName ) &&
						namespaceIsAncestor( ln ) )
					{
						n = ln;
						break;
					}
				}
			}
			if( !_namespaces.hasOwnProperty( n ) )
				_namespaces[ n ] = {};
			_namespaces[ n ][ inName.localName ] = inValue;
		}
		
		/**
		 * @private
		 */
		private function namespaceIsAncestor( inNamespace : String ) : Boolean
		{
			var element : IWorkflowElement = _runningTask;
			while( element != null )
			{
				if( UIDUtil.getUID( element ) == inNamespace )
					return true;
				element = element.parent;
			}
			return false;
		}
		
		/**
		 * @private
		 */
		override flash_proxy function getProperty( inName : * ) : *
		{
			if( inName.localName.match( /^i\d+$/ ) )
			{
				return getAncestorI( int( inName.localName.match( /^i(\d+)$/ )[1] ) ) ;
			}
			
			if( inName.localName.match( /^currentData\d+$/ ) )
			{
				return getAncestorCurrentData( int( inName.localName.match( /^currentData(\d+)$/ )[1] ) ) ;
			}
			
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