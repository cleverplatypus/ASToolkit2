package org.astoolkit.workflow.core
{
	
	import flash.utils.getQualifiedClassName;
	import mx.events.PropertyChangeEvent;
	
	public class RequiresVariable extends BaseTask
	{
		
		[Inspectable( enumeration="wait,fail", defaultValue="fail" )]
		public var behaviour : String = "fail";
		
		public var name : String;
		
		public var type : Class;
		
		public var notNull : Boolean;
		
		override public function begin() : void
		{
			super.begin();
			
			if ( $[ name ] === undefined )
			{
				if ( behaviour == "wait" || parent == root )
				{
					$.addEventListener( 
						PropertyChangeEvent.PROPERTY_CHANGE,
						threadSafe( onVariableProviderChange ) );
					return;
				}
				else
					fail( "Variable {0} not set", name );
			}
			else
			{
				if ( isRightType() )
					complete();
			}
		}
		
		private function onVariableProviderChange( inEvent : PropertyChangeEvent ) : void
		{
			if ( inEvent.property == name && isRightType() )
				complete();
		}
		
		private function isRightType() : Boolean
		{
			if ( !notNull && $[ name ] == null )
				return true;
			
			if ( type != null && !( $[ name ] is type ) )
			{
				fail( "Unexpected variable value. Expected '{0}', found '{1}'",
					getQualifiedClassName( type ),
					$[ name ] == null ? "null" : getQualifiedClassName( $[ name ] ) );
				return false;
			}
			return true;
		}
	}
}
