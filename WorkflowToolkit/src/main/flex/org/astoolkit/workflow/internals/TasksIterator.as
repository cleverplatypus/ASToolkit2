package org.astoolkit.workflow.internals
{
	
	import flash.events.IEventDispatcher;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.workflow.api.IWorkflow;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.core.WorkflowEvent;
	
	public class TasksIterator implements IIterator
	{
		public function TasksIterator()
		{
		}
		
		private var _current : IWorkflowTask;
		
		private var _currentIndex : int;
		
		private var _elements : Vector.<IWorkflowTask>;
		
		private var _hasNextInvalidated : Boolean;
		
		private var _isAborted : Boolean;
		
		private var _pendingTasks : Vector.<IWorkflowTask>;
		
		private var _prefetchedIndex : int;
		
		private var _prefetchedTask : IWorkflowTask;
		
		private var _workflow : IWorkflow;
		
		public function abort() : void
		{
			_isAborted = true;
		}
		
		public function current() : Object
		{
			return _current;
		}
		
		public function currentIndex() : Number
		{
			return _currentIndex;
		}
		
		public function hasNext() : Boolean
		{
			if(_hasNextInvalidated)
			{
				prefetchNext();
				_hasNextInvalidated = false;
			}
			return _prefetchedTask != null;
		}
		
		public function get hasPendingTasks() : Boolean
		{
			return _pendingTasks.length > 0;
		}
		
		public function get isAborted() : Boolean
		{
			return _isAborted;
		}
		
		public function next() : Object
		{
			if(hasNext())
			{
				_hasNextInvalidated = true;
				_current = _prefetchedTask;
				_currentIndex = _prefetchedIndex;
				_current.addEventListener(
					WorkflowEvent.STARTED,
					onTaskStart );
				IEventDispatcher( _current.document ).dispatchEvent(
					new PropertyChangeEvent(
					PropertyChangeEvent.PROPERTY_CHANGE,
					false,
					false,
					PropertyChangeEventKind.UPDATE,
					"$",
					Math.random(),
					_current.context.variables,
					_current.document
					));
				return _current;
			}
			return null;
		}
		
		public function get progress() : Number
		{
			if(_elements && _elements.length > 0)
				return _currentIndex / _elements.length;
			return -1;
		}
		
		public function reset() : void
		{
			_hasNextInvalidated = true;
			_currentIndex = -1;
			_prefetchedIndex = -1;
			_isAborted = false;
			_current = null;
			_prefetchedTask = null;
			_elements = GroupUtil.getRuntimeTasks( _workflow.children );
			
			if(!_pendingTasks)
				_pendingTasks = new Vector.<IWorkflowTask>();
			else if(_pendingTasks.length > 0)
			{
				for each(var task : IWorkflowTask in _pendingTasks)
					task.removeEventListener(
						WorkflowEvent.COMPLETED,
						onTaskComplete );
				_pendingTasks.splice( 0, _pendingTasks.length );
			}
		}
		
		public function set source( inValue : * ) : void
		{
			if(!(inValue is IWorkflow))
				throw new Error( "TaskIterator source must be an instance of IWorkflow" );
			_workflow = inValue as IWorkflow;
		}
		
		public function supportsSource( inObject : * ) : Boolean
		{
			return inObject is IWorkflow;
		}
		
		private function onTaskComplete( inEvent : WorkflowEvent ) : void
		{
			IWorkflowTask( inEvent.target ).removeEventListener(
				WorkflowEvent.COMPLETED,
				onTaskComplete );
			_pendingTasks.splice( _pendingTasks.indexOf( IWorkflowTask( inEvent.target )), 1 );
		}
		
		private function onTaskStart( inEvent : WorkflowEvent ) : void
		{
			IWorkflowTask( inEvent.target ).removeEventListener(
				WorkflowEvent.STARTED,
				onTaskStart );
			IWorkflowTask( inEvent.target ).addEventListener(
				WorkflowEvent.COMPLETED,
				onTaskComplete );
		}
		
		private function prefetchNext() : void
		{
			var task : IWorkflowTask;
			_prefetchedIndex++;
			
			if(_prefetchedIndex < _elements.length)
				_prefetchedTask = _elements[_prefetchedIndex];
			else
				_prefetchedTask = null;
		}
	}
}
