package org.astoolkit.commons.collection
{
	import flash.utils.ByteArray;
	
	import org.astoolkit.commons.collection.api.IIterator;
	
	[IteratorSource("flash.utils.ByteArray")]
	public class ByteArrayIterator implements IIterator
	{
		public var readChunk : uint = 1024;
		private var _source : ByteArray;
		private var _isAborted : Boolean;
		private var _current : ByteArray;
		
		public function set source(inValue:*):void
		{
			_source = inValue as ByteArray;
		}
		
		public function hasNext():Boolean
		{
			return _source && _source.bytesAvailable > 0;
		}
		
		public function next() : Object
		{
			if( _source )
			{
				if( !_current )
					_current = new ByteArray();
				_current.clear();
				_source.readBytes( _current, 0, Math.min( _source.bytesAvailable, readChunk ) );
				return current();
			}
			return null;
		}
		
		public function current():Object
		{
			return _current;
		}
		
		public function reset():void
		{
			if( _source )
				_source.position = 0;
			_current = null;
			_isAborted = false;
		}
		
		public function currentIndex():Number
		{
			if( _source )
				return Math.ceil( ( _source.position - readChunk ) / readChunk ); 
			return -1;
		}
		
		public function supportsSource(inObject:*):Boolean
		{
			return inObject is ByteArray;
		}
		
		public function get progress():Number
		{
			if( _source )
				return ( _source.position / readChunk ) /
					( _source.length / readChunk );
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