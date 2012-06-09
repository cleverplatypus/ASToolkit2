package org.astoolkit.commons.collection
{
	import org.astoolkit.commons.collection.api.IIterator;

	[IteratorSource("null")]
	public class InfiniteIterator implements IIterator
	{
		
		private var _isAborted : Boolean;

		public function set source( inValue : * ) : void
		{

		}
		
		public function hasNext():Boolean
		{
			return true;
		}
		
		public function next():Object
		{
			return null;
		}
		
		public function current():Object
		{
			return null;
		}
		
		public function reset() : void
		{
			_isAborted = false;
		}
		
		public function currentIndex() : Number
		{
			return -1;
		}
		
		public function supportsSource( inObject : * ) : Boolean
		{
			return inObject == null;
		}
		
		public function get progress():Number
		{
			return -1;
		}
		
		public function abort():void
		{
			_isAborted = true;
		}
		
		public function get isAborted():Boolean
		{
			return _isAborted;
		}
	}
}