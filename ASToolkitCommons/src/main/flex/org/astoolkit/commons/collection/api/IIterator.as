package org.astoolkit.commons.collection.api
{
	
	import mx.collections.IList;
	
	public interface IIterator
	{
		function abort() : void;
		function current() : Object;
		function currentIndex() : Number;
		function hasNext() : Boolean;
		function get isAborted() : Boolean;
		function next() : Object;
		function get progress() : Number;
		function reset() : void;
		function set source( inValue : * ) : void;
		function supportsSource( inObject : * ) : Boolean;
	}
}
