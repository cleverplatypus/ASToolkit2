package org.astoolkit.commons.databinding
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import mx.binding.IBindingClient;
	
	import org.astoolkit.commons.reflection.ClassInfo;
	import org.astoolkit.commons.reflection.FieldInfo;

	import mx.core.mx_internal;
	
	use namespace mx_internal;
	//TODO: optimize theId search. Use caching
	public class BindingUtility
	{
		private static var _cache : Dictionary = new Dictionary(true);
		private static var _bindingManager : Object;
		
		private static function get bindingManager() : Object
		{
			if( !_bindingManager )
				_bindingManager = getDefinitionByName( "mx.binding.BindingManager" );
			return _bindingManager;
		}
		
		public static function firePropertyBinding( inOwner : Object, inTarget : Object, inProperty : String ) : void
		{
			var theId : String = getId( inOwner, inTarget );
			if( theId )
			{
				bindingManager.enableBindings( inOwner, theId + "." + inProperty, true );
				bindingManager.executeBindings( inOwner, theId + "." + inProperty, inTarget );
				bindingManager.executeBindings( inOwner, theId + "." + inProperty, false );
			}
		}
		
		public static function enablePropertyBinding( inOwner : Object, inTarget : Object, inProperty : String ) : void
		{
			switchBindings( inOwner, inTarget, true, inProperty );
		}
		
		public static function disablePropertyBinding( inOwner : Object, inTarget : Object, inProperty : String ) : void
		{
			switchBindings( inOwner, inTarget, false, inProperty );
		}
		
		public  static function enableAllBindings( inOwner : Object, inTarget : Object ) : void
		{
			switchBindings( inOwner, inTarget, true );
		}
		
		public  static function disableAllBindings( inOwner : Object, inTarget : Object ) : void
		{
			switchBindings( inOwner, inTarget, false );
		}
		
		private static function switchBindings( inOwner : Object, inTarget : Object, inEnable : Boolean, inProperty : String = null ) : void
		{
			var bindingManager : Object = getDefinitionByName( "mx.binding.BindingManager" );
			var theId : String = getId( inOwner, inTarget );
			
			if( theId )
			{
				var targetInfo : ClassInfo = ClassInfo.forType( inTarget );
				var fields : Vector.<FieldInfo> =
					inProperty != null ? 
						Vector.<FieldInfo>( [ targetInfo.getField( inProperty ) ] ):
						targetInfo.getFields();
				for each(var field : FieldInfo in fields )
				{
					if( ( field.writeOnly || field.fullAccess ) && field.scope == FieldInfo.SCOPE_PUBLIC )
					{
						bindingManager.enableBindings( inOwner, theId + "." + field.name, inEnable );
						if( inEnable )
							bindingManager.executeBindings( inOwner, theId + "." + field.name, inTarget );
					}
				}
			}

		}
		
		public static function propertyHasBindings( inOwner : Object, inTarget : Object, inProperty : String ) : Boolean
		{
			var theId : String = getId( inOwner, inTarget );
			return inOwner is IBindingClient &&
				inOwner[ "_bindingsByDestination" ].hasOwnProperty( theId + "." + inProperty );
		}
		
		private static function getId( inOwner : Object, inTarget : Object ) : String
		{
			if( inTarget.hasOwnProperty( "id" ) && 
				inOwner.hasOwnProperty( inTarget[ "id" ] ) &&
				inOwner[ inTarget[ "id" ] ] == inTarget )
				return inTarget[ "id" ];
			if( !_cache.hasOwnProperty( inTarget ) )
			{
				var ownerInfo : ClassInfo = ClassInfo.forType( inOwner );
				var targetInfo : ClassInfo = ClassInfo.forType( inTarget );
				
				for each( var f : FieldInfo in ownerInfo.getFields() )
				{
					if( f.fullAccess && f.scope == FieldInfo.SCOPE_PUBLIC && inOwner[ f.name ] == inTarget )
					{
						_cache[ inTarget ] = f.name
					}
				}
			}
			return _cache[ inTarget ] as String;
		}
	}
}