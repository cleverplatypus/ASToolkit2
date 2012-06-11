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
package org.astoolkit.commons.collection.api
{

	/**
	 * Contract for an iterator class.
	 * <p>Iterators are objects that, given a source object,
	 * provide a set of values on subsequent calls to the <code>next()</code>method.</p>
	 * <p>Iterators can be interrupted calling <code>abort()</code></p>
	 */
	public interface IIterator
	{
		/**
		 * Interrupts the iteration. Typically, after calling this method,
		 * <code>isAborted</code> will return true.
		 */
		function abort() : void;
		/**
		 * returns the current value of this iteration without
		 * moving the cursor to the next element of the iteration
		 */
		function current() : Object;
		/**
		 * returns the numeric index of the iteration
		 */
		function currentIndex() : Number;

		/**
		 * returns true if this iterator is able to provide
		 * a value when calling <code>next()</code>
		 */
		function hasNext() : Boolean;
		/**
		 * true if <code>abort()</code> was previously called
		 */
		function get isAborted() : Boolean;

		/**
		 * tries to move to the next element of the iteration
		 * and returns it. If the iterator was aborted or already
		 * at the last element, it should throw an Error
		 */
		function next() : Object;

		/**
		 * a value between 0 and 1 reppresenting
		 * the iteration's progress
		 */
		function get progress() : Number;

		/**
		 * makes the iterator ready for a new iteration.
		 * Any index should be reset here. <code>isAborted</code> should
		 * be reset to false too
		 */
		function reset() : void;

		/**
		 * the source object for this iteration, typically a list
		 * or any other object with enumerable properties
		 */
		function set source( inValue : * ) : void;

		/**
		 * returns true if the passed value can be handled
		 * by this iterator
		 */
		function supportsSource( inObject : * ) : Boolean;
	}
}
