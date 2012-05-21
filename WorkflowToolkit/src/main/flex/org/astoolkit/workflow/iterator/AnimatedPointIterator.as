package org.astoolkit.workflow.iterator
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
		public var startX : Number = 0;
		public var endX : Number = 1;
		
		public var startY : Number = 0;
		public var endY : Number = 1;
		
		public var steps : int = -1;
		
		private var _linearEaser : Linear = new Linear();
		private var _isAborted : Boolean;
		
		public var easerX : IEaser = _linearEaser;
		public var easerY : IEaser = _linearEaser;
		
		private var _currentFraction : Number;
		
		private function getActualSteps() : int
		{
			return steps > -1 ? steps : endX - startX + 1;
		}
		
		
		public function abort():void
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
		
		public function hasNext():Boolean
		{
			return _currentFraction < 1;
		}
		
		public function get isAborted():Boolean
		{
			return _isAborted;
		}
		
		public function next() : Object
		{
			_currentFraction += ( 1 / getActualSteps() );
			return current();
		}
		
		public function get progress():Number
		{
			// TODO Auto Generated method stub
			return _currentFraction;
		}
		
		public function reset():void
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
		
	}
}