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
package org.astoolkit.workflow.flex4.iterator
{

	import org.astoolkit.commons.collection.BaseIterator;
	import spark.effects.easing.IEaser;
	import spark.effects.easing.Linear;

	/**
	 * An iterator that uses an <code>Easer</code> to generate
	 * values from <code>startValue</code> to <code>endValue</code>.
	 * <p>The default easer is <code>spark.effects.easing.Linear</code></p>
	 */
	public class AnimatedValueIterator extends BaseIterator
	{

		private var _currentFraction : Number;

		private var _cycle : Boolean;

		private var _isAborted : Boolean;

		private var _linearEaser : Linear = new Linear();

		override public function set cycle( inValue :Boolean) : void
		{
			_cycle = inValue;
		}

		public var easer : IEaser = _linearEaser;

		public var endValue : Number = 1;

		override public function get isAborted() : Boolean
		{
			return _isAborted;
		}

		override public function get progress() : Number
		{
			return _currentFraction;
		}

		override public function set source( inValue : * ) : void
		{
			//Ignored. Source is generated internally
		}

		public var startValue : Number = 0;

		public var steps : int = -1;

		override public function abort() : void
		{
			_isAborted = true;
		}

		override public function current() : Object
		{
			return ( endValue - startValue ) * easer.ease( _currentFraction );
		}

		override public function currentIndex() : Number
		{
			return getActualSteps() * _currentFraction;
		}

		override public function hasNext() : Boolean
		{
			return _currentFraction < 1;
		}

		override public function next() : Object
		{
			_currentFraction += ( 1 / getActualSteps() );
			return current();
		}

		override public function pushBack() : void
		{
		}

		override public function reset() : void
		{
			_currentFraction = 0;
		}

		override public function supportsSource( inObject : * ) : Boolean
		{
			//This iterator can only be declared explicitly
			return false;
		}

		private function getActualSteps() : int
		{
			return steps > -1 ? steps : endValue - startValue + 1;
		}
	}
}
