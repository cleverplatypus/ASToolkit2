package org.astoolkit.commons.collection
{
	
	import mx.collections.IList;
	import mx.collections.XMLListCollection;
	import org.astoolkit.commons.collection.api.IIterator;
	
	[IteratorSource( "Array,Vector,mx.collections.IList,XMLList" )]
	public class ListIterator implements IIterator
	{
		private var _list : Object;
		
		protected var _currentDataIndex : int = -1;
		
		protected var _isAborted : Boolean;
		
		public function reset() : void
		{
			_currentDataIndex = -1;
			_isAborted = false;
		}
		
		public function set source( inValue : * ) : void
		{
			if ( inValue &&
				!( inValue is IList || inValue is Array || inValue is Vector || inValue is XMLList ) )
				throw new Error( "list must be one of IList, Array, Vector, XMLList, XMListCollection" );
			_list = inValue;
			reset();
		}
		
		private function getListLength() : int
		{
			if ( !_list )
				return 0;
			return _list is XMLList ? XMLList( _list ).length() : _list.length;
		}
		
		public function hasNext() : Boolean
		{
			return _list != null &&
				getListLength() > 0 &&
				_currentDataIndex + 1 < getListLength();
		}
		
		public function next() : Object
		{
			if ( !_list || getListLength() == 0 || _currentDataIndex + 1 >= getListLength() )
				return null;
			_currentDataIndex++;
			return _list[ _currentDataIndex ];
		}
		
		public function current() : Object
		{
			if ( currentIndex() == -1 )
				return null;
			
			if ( !_list || getListLength() == 0 || _currentDataIndex >= getListLength() )
				return null;
			return _list[ _currentDataIndex ];
		}
		
		public function currentIndex() : Number
		{
			return _currentDataIndex;
		}
		
		public function supportsSource( inValue : * ) : Boolean
		{
			return inValue is IList || inValue is Array || inValue is Vector || inValue is XMLList;
		}
		
		public function get progress() : Number
		{
			if ( _list && _currentDataIndex > -1 )
				return _currentDataIndex / getListLength();
			return -1;
		}
		
		public function abort() : void
		{
			_isAborted = true;
		}
		
		public function get isAborted() : Boolean
		{
			return _isAborted;
		}
	}
}
