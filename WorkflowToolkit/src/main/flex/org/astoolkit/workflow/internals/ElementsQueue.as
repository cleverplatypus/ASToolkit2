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

	import mx.utils.ArrayUtil;
	import org.astoolkit.commons.process.api.IDeferrableProcess;
	import org.astoolkit.workflow.api.ITaskLiveCycleWatcher;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.api.IWorkflowTask;

	public class ElementsQueue
	{

		private var _currentElementsIndex : int = -1;

		private var _deferredElements : Object;

		private var _elements : Vector.<IWorkflowElement>;

		private var _executingTasks : Object;

		private var _resumed: Vector.<IWorkflowElement>;

		public function ElementsQueue(  inElements : Vector.<IWorkflowElement>  )
		{
			_elements = inElements;
		}

		public function hasNext() : Boolean
		{
			return ( _resumed && _resumed.length > 0 ) || ( _elements != null && 
				_elements.length > _currentElementsIndex+1 );
		}

		public function hasPendingElements() : Boolean
		{
			var p : String;

			if( p in _deferredElements )
				return true;

			if( p in _executingTasks )
				return true;
			return hasNext();
		}

		public function init() : void
		{
			_deferredElements = {};
			_executingTasks = {};
			_currentElementsIndex = -1;
			_resumed = new Vector.<IWorkflowElement>();
		}

		public function next() : IWorkflowElement
		{
			if( !hasNext() )
				return null;

			if( _resumed.length > 0 )
				return _resumed.pop();
			_currentElementsIndex++;
			return _elements[ _currentElementsIndex ];
		}

		public function onDeferredElementResume( inElement : IDeferrableProcess ) : void
		{
			_resumed.push( inElement as IWorkflowElement );

			if( _deferredElements.hasOwnProperty( inElement ) )
				delete _deferredElements[ inElement ];
		}

		public function onElementProcessDeferred( inTask : IDeferrableProcess ) : void
		{
			_deferredElements[ inTask ] = inTask;
		}

		public function onTaskBegin( inTask : IWorkflowTask ) : void
		{
			_executingTasks[ inTask ] = inTask;
		}

		public function onTaskComplete( inTask : IWorkflowTask ) : void
		{
			if( _executingTasks.hasOwnProperty( inTask ) )
				delete _executingTasks[ inTask ];
		}
	}
}
