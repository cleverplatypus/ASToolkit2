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

	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import org.astoolkit.commons.collection.api.IIterator;

	[IteratorSource( "flash.filesystem.FileStream" )]
	public class FileStreamIterator extends BaseIterator
	{

		private var _current : ByteArray;

		private var _cycle : Boolean;

		private var _isAborted : Boolean;

		private var _source : FileStream;

		private var _totalLength : uint;

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
			if( _source )
				return ( _source.position / readChunk ) /
					( _totalLength / readChunk );
			return -1;
		}

		public var readChunk : uint = 1024;

		override public function set source( inValue : * ) : void
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

		override public function abort() : void
		{
			_isAborted = true;
		}

		override public function current() : Object
		{
			return _current;
		}

		override public function currentIndex() : Number
		{
			if( _source )
				return Math.ceil( ( _source.position - readChunk ) / readChunk );
			return -1;
		}

		override public function hasNext() : Boolean
		{
			return _source && _source.bytesAvailable > 0;
		}

		override public function next() : Object
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

		override public function pushBack() : void
		{
			// TODO Auto Generated method stub

		}

		override public function reset() : void
		{
			if( _source )
				_source.position = 0;
			_current = null;
			_isAborted = false;
		}

		override public function supportsSource( inObject : * ) : Boolean
		{
			return inObject is FileStream;
		}
	}
}
