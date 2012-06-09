package org.astoolkit.commons.collection
{
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import org.astoolkit.commons.collection.api.IIterator;
	
	[IteratorSource("flash.filesystem.FileStream")]
	public class FileStreamIterator implements IIterator
	{
		public var readChunk : uint = 1024;
		private var _source : FileStream;
		private var _isAborted : Boolean;
		private var _current : ByteArray;
		private var _totalLength : uint;
		
		public function set source(inValue:*):void
		{
			_source = inValue as FileStream;
			if( _source )
			{
				var oldPosition : uint = _source.position;
				_source.position = 0;
				_totalLength = _source.bytesAvailable;
				_source.position = oldPosition;
			}
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
			return inObject is FileStream;
		}
		
		public function get progress() : Number
		{
			if( _source )
				return ( _source.position / readChunk ) /
					( _totalLength / readChunk );
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