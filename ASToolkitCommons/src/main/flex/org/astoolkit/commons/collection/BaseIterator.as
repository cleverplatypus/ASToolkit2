package org.astoolkit.commons.collection
{
	import org.astoolkit.commons.collection.api.IIterator;
	
	public class BaseIterator implements IIterator
	{
		public function BaseIterator()
		{
		}
		
		public function set cycle(inValue:Boolean):void
		{
		}
		
		public function get isAborted():Boolean
		{
			return false;
		}
		
		public function get progress():Number
		{
			return 0;
		}
		
		public function set source(inValue:*):void
		{
		}
		
		public function abort():void
		{
		}
		
		public function current():Object
		{
			return null;
		}
		
		public function currentIndex():Number
		{
			return 0;
		}
		
		public function hasNext():Boolean
		{
			return false;
		}
		
		public function next():Object
		{
			return null;
		}
		
		public function pushBack():void
		{
		}
		
		public function reset():void
		{
		}
		
		public function supportsSource(inObject:*):Boolean
		{
			return false;
		}
		
		public function get pid():String
		{
			return null;
		}
		
		public function set pid(inValue:String):void
		{
		}
	}
}