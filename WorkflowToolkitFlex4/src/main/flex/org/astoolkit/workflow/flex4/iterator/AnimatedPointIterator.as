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

	import flash.geom.Point;
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.workflow.core.BaseTask;
	import spark.effects.Animate;
	import spark.effects.animation.SimpleMotionPath;
	import spark.effects.easing.IEaser;
	import spark.effects.easing.Linear;

	public class AnimatedPointIterator implements IIterator
	{
		public var easerX : IEaser = _linearEaser;

		public var easerY : IEaser = _linearEaser;

		public var endX : Number = 1;

		public var endY : Number = 1;

		public var startX : Number = 0;

		public var startY : Number = 0;

		public var steps : int = -1;

		private var _currentFraction : Number;

		private var _isAborted : Boolean;

		private var _linearEaser : Linear = new Linear();

		public function abort() : void
		{
			_isAborted = true;
		}

		public function current() : Object
		{
			return new Point( ( endX - startX ) * easerX.ease( _currentFraction ), ( endY - startY ) * easerY.ease( _currentFraction ) );
		}

		public function currentIndex() : Number
		{
			return getActualSteps() * _currentFraction;
		}

		public function hasNext() : Boolean
		{
			return _currentFraction < 1;
		}

		public function get isAborted() : Boolean
		{
			return _isAborted;
		}

		public function next() : Object
		{
			_currentFraction += ( 1 / getActualSteps() );
			return current();
		}

		public function get progress() : Number
		{
			return _currentFraction;
		}

		public function pushBack() : void
		{

		}

		public function reset() : void
		{
			_currentFraction = 0;
		}

		public function set source( inValue : * ) : void
		{
			//Ignored. Source is generated internally
		}

		public function supportsSource( inObject : * ) : Boolean
		{
			return false;
		}

		private function getActualSteps() : int
		{
			return steps > -1 ? steps : endX - startX + 1;
		}
	}
}
