package org.astoolkit.workflow.task.mapping
{
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.workflow.api.IMapTask;
	import org.astoolkit.workflow.core.BaseTask;
	
	public class MapValue extends BaseTask implements IMapTask
	{
		
		public var propertyName : String;
		
		public var value : Object;
		
		public var mandatory : Boolean = true;
		
		override public function set inputFilter( inValue : Object ) : void
		{
			throw new Error( "inputFilter cannot be set for MapValue objects." +
				"Use the 'map' property instead" );
		}
		
		public function set map( inExpression : Object ) : void
		{
			_inputFilter = inExpression;
		}
		
		override public function begin():void
		{
			super.begin();
			if( !target || !propertyName || !target.hasOwnProperty( propertyName ) )
			{
				if( !mandatory )
				{
					complete();
					return;
				}
			}
			if( astoolkit_private::propertyIsUserDefined( "value" )  )
				target[ propertyName ] = value;
			else
				target[ propertyName ] = filteredInput;
			complete();
		}
		
		
		public function set source(inValue:Object):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function get source():Object
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function set target(inValue:Object):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function get target():Object
		{
			// TODO Auto Generated method stub
			return null;
		}
		
	}
}