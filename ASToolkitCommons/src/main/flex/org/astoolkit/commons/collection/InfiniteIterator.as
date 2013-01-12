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

	[IteratorSource( "null" )]
	public class InfiniteIterator extends BaseIterator
	{
		private var _cycle : Boolean;

		private var _index : int;

		private var _isAborted : Boolean;

		override public function set cycle( inValue :Boolean) : void
		{
			_cycle = inValue;
		}

		override public function get isAborted() : Boolean
		{
			return _isAborted;
		}

		override public function get progress() : Number
		{
			return -1;
		}

		override public function set source( inValue : * ) : void
		{
		}

		override public function abort() : void
		{
			_isAborted = true;
		}

		override public function current() : Object
		{
			return null;
		}

		override public function currentIndex() : Number
		{
			return -1;
		}

		override public function hasNext() : Boolean
		{
			return true;
		}

		override public function next() : Object
		{
			_index++;
			return null;
		}

		override public function pushBack() : void
		{
			// TODO Auto Generated method stub

		}

		override public function reset() : void
		{
			_isAborted = false;
			_index = -1;
		}

		override public function supportsSource( inObject : * ) : Boolean
		{
			return inObject == null;
		}
	}
}
