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
package org.astoolkit.commons.collection
{
	
	import org.astoolkit.commons.collection.api.IIterator;
	
	[IteratorSource( "Number,int,uint" )]
	public class CountIterator implements IIterator
	{
		public function CountIterator()
		{
			countTo = int.MIN_VALUE;
		}
		
		public var countFrom : int = 0;
		
		public var countTo : int;
		
		private var _currentCount : int;
		
		private var _isAborted : Boolean;
		
		public function abort() : void
		{
			_isAborted = true;
		}
		
		public function current() : Object
		{
			return _currentCount;
		}
		
		public function currentIndex() : Number
		{
			return _currentCount;
		}
		
		public function hasNext() : Boolean
		{
			return countTo != int.MIN_VALUE && _currentCount < countTo;
		}
		
		public function get isAborted() : Boolean
		{
			return _isAborted;
		}
		
		public function next() : Object
		{
			_currentCount++;
			return _currentCount;
		}
		
		public function get progress() : Number
		{
			return countFrom / countTo;
		}
		
		public function reset() : void
		{
			_currentCount = countFrom - 1;
			countTo = int.MIN_VALUE;
			_isAborted = false;
		}
		
		public function set source( inValue : * ) : void
		{
			if(!isNaN( inValue ) && inValue != null)
				countTo = int( inValue );
		}
		
		public function supportsSource( inObject : * ) : Boolean
		{
			return !isNaN( inObject );
		}
	}
}
