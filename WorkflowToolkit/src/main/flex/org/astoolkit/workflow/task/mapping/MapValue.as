package org.astoolkit.workflow.task.mapping
{
	
	import mx.core.IFactory;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.workflow.api.IMapTask;
	import org.astoolkit.workflow.core.BaseTask;
	
	public class MapValue extends BaseTask implements IMapTask
	{
		
		[Bindable]
		public var property : String;
		
		public var value : Object;
		
		[Bindable]
		public var target : Object;
		
		public var mandatory : Boolean = true;
		
		private var _target : IFactory;
		
		override public function set inputFilter( inValue : Object ) : void
		{
			throw new Error( "inputFilter cannot be set for MapValue objects." +
				"Use the 'map' property instead" );
		}
		
		public function set map( inExpression : Object ) : void
		{
			_inputFilter = inExpression;
		}
		
		override public function begin() : void
		{
			super.begin();
			var targetObject : Object = targetClass.newInstance();
			
			if ( !targetObject || !property || !targetObject.hasOwnProperty( property ) )
			{
				if ( !mandatory )
				{
					complete();
					return;
				}
			}
			
			if ( astoolkit_private::propertyIsUserDefined( "value" ) )
				targetObject[ property ] = value;
			else
				targetObject[ property ] = filteredInput;
			complete();
		}
		
		public function set source(inValue:Object) : void
		{
			// TODO Auto Generated method stub
		}
		
		public function get source() : Object
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function set targetClass(inValue:IFactory) : void
		{
			_target = inValue;
		}
		
		public function get targetClass() : IFactory
		{
			return _target;
		}
	}
}
