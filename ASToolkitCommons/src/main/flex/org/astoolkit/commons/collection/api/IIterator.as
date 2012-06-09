package org.astoolkit.commons.collection.api
{
	
	import mx.collections.IList;
	
	public interface IIterator
	{
		function set source( inValue : * ) : void;
		function hasNext() : Boolean;
		function next() : Object;
		function current() : Object;
		function reset() : void;
		function currentIndex() : Number;
		function supportsSource( inObject : * ) : Boolean;
		function get progress() : Number;
		function abort() : void;
		function get isAborted() : Boolean;
	}
}
