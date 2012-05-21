package org.astoolkit.commons.collection
{
	import org.astoolkit.commons.collection.api.IIterator;

	[IteratorSource("null")]
	public class CountIterator implements IIterator
	{
		
		private var _currentCount : int;
		private var _isAborted : Boolean;
		
		
		public var countFrom : int = 0;
		public var countTo : int;
		
		
		public function CountIterator()
		{
			countTo = int.MAX_VALUE
		}
		public function set source(inValue:*):void
		{
			if( !isNaN( inValue ) && inValue != null )
				countTo = int( inValue );
		}
		
		public function hasNext():Boolean
		{
			return _currentCount < countTo;
		}
		
		public function next():Object
		{
			_currentCount++;
			return _currentCount;
		}
		
		public function current():Object
		{
			return _currentCount;
		}
		
		public function reset():void
		{
			_currentCount = countFrom -1;
			_isAborted = false;
		}
		
		public function currentIndex() : Number
		{
			return _currentCount;
		}
		
		public function supportsSource(inObject:*):Boolean
		{
			return inObject == null;
		}
		
		public function get progress():Number
		{
			return countFrom / countTo;
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