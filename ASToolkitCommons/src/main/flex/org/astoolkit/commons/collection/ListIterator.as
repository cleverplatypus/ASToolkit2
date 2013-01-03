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

	import mx.collections.IList;
	import mx.collections.XMLListCollection;
	import org.astoolkit.commons.collection.api.IIterator;

	[IteratorSource( "Array,Vector,mx.collections.IList,XMLList" )]
	public class ListIterator implements IIterator
	{
		private var _cycle : Boolean;

		private var _list : Object;

		protected var _currentDataIndex : int = -1;

		protected var _isAborted : Boolean;

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
			if( _list && _currentDataIndex > -1 )
				return _currentDataIndex / getListLength();
			return -1;
		}

		public function set source( inValue : * ) : void
		{
			if( inValue &&
				!( inValue is IList || inValue is Array || inValue is Vector || inValue is XMLList ) )
				throw new Error( "list must be one of IList, Array, Vector, XMLList, XMListCollection" );
			_list = inValue;
			reset();
		}

		public function abort() : void
		{
			_isAborted = true;
		}

		public function current() : Object
		{
			if( currentIndex() == -1 )
				return null;

			if( !_list || getListLength() == 0 || _currentDataIndex >= getListLength() )
				return null;
			return _list[ _currentDataIndex ];
		}

		public function currentIndex() : Number
		{
			return _currentDataIndex;
		}

		public function hasNext() : Boolean
		{
			return _cycle || ( _list != null &&
				getListLength() > 0 &&
				_currentDataIndex + 1 < getListLength() );
		}

		public function next() : Object
		{
			if( _cycle && !_list &&  
				_currentDataIndex + 1 >= getListLength() )
				reset();

			if( !_list || getListLength() == 0 || _currentDataIndex + 1 >= getListLength() )
				return null;
			_currentDataIndex++;
			return _list[ _currentDataIndex ];
		}

		public function pushBack() : void
		{
			if( _currentDataIndex > -1 )
				_currentDataIndex--;
		}

		public function reset() : void
		{
			_currentDataIndex = -1;
			_isAborted = false;
		}

		public function supportsSource( inValue : * ) : Boolean
		{
			return inValue is IList || inValue is Array || inValue is Vector || inValue is XMLList;
		}

		private function getListLength() : int
		{
			if( !_list )
				return 0;
			return _list is XMLList ? XMLList( _list ).length() : _list.length;
		}
	}
}
