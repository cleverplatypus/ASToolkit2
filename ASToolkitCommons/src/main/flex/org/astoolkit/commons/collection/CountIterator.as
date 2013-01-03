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
	import org.astoolkit.commons.utils.Range;

	[IteratorSource( "org.astoolkit.commons.utils.Range,Number,int,uint" )]
	public class CountIterator implements IIterator
	{

		private var _currentCount : int;

		private var _cycle : Boolean;

		private var _isAborted : Boolean;

		public var countFrom : int = 0;

		public var countTo : int;

		public function set cycle(value:Boolean) : void
		{
			_cycle = value;
		}

		public function get isAborted() : Boolean
		{
			return _isAborted;
		}

		public function get progress() : Number
		{
			return countFrom / countTo;
		}

		public function set source( inValue : * ) : void
		{
			if( inValue is Range )
			{
				countFrom = Range( inValue ).from;
				countTo = Range( inValue ).to;
				return;
			}
			else if( !isNaN( inValue ) && inValue != null )
				countTo = int( inValue );
		}

		public function CountIterator()
		{
			countTo = int.MIN_VALUE;
		}

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

		public function next() : Object
		{
			_currentCount++;
			return _currentCount;
		}

		public function pushBack() : void
		{
			_currentCount --;
		}

		public function reset() : void
		{
			_currentCount = countFrom - 1;
			_isAborted = false;
		}

		public function supportsSource( inObject : * ) : Boolean
		{
			return ( inObject is Range && !isNaN( Range( inObject ).from ) )
				|| !isNaN( inObject );
		}
	}
}
