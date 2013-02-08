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
package org.astoolkit.commons.databinding
{

	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	import mx.binding.IBindingClient;
	import mx.core.mx_internal;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;

	import org.astoolkit.commons.reflection.Type;
	import org.astoolkit.commons.reflection.Field;

	use namespace mx_internal;

	//TODO: optimize theId search. Use caching
	public class BindingUtility
	{
		private static var _bindingManager : Object;

		private static var _cache : Dictionary = new Dictionary( true );

		public static function disableAllBindings( inOwner : Object, inTarget : Object ) : void
		{
			switchBindings( inOwner, inTarget, false );
		}

		public static function disablePropertyBinding( inOwner : Object, inTarget : Object, inProperty : String ) : void
		{
			switchBindings( inOwner, inTarget, false, inProperty );
		}

		public static function enableAllBindings( inOwner : Object, inTarget : Object ) : void
		{
			switchBindings( inOwner, inTarget, true );
		}

		public static function enablePropertyBinding( inOwner : Object, inTarget : Object, inProperty : String ) : void
		{
			switchBindings( inOwner, inTarget, true, inProperty );
		}

		public static function touch( inTarget : Object, inProperty : String, inNewValue : * = null ) : void
		{
			if( !( inTarget is IEventDispatcher ) )
				return;
			IEventDispatcher( inTarget ).dispatchEvent(
				new PropertyChangeEvent(
				PropertyChangeEvent.PROPERTY_CHANGE,
				false,
				false,
				PropertyChangeEventKind.UPDATE,
				inProperty,
				Math.random(),
				inNewValue
				) );
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

		public static function propertyHasBindings( inOwner : Object, inTarget : Object, inProperty : String ) : Boolean
		{
			var theId : String = getId( inOwner, inTarget );
			return inOwner is IBindingClient &&
				inOwner[ "_bindingsByDestination" ].hasOwnProperty( theId + "." + inProperty );
		}

		private static function get bindingManager() : Object
		{
			if( !_bindingManager )
				_bindingManager = getDefinitionByName( "mx.binding.BindingManager" );
			return _bindingManager;
		}

		private static function getId( inOwner : Object, inTarget : Object ) : String
		{
			if( inTarget.hasOwnProperty( "id" ) &&
				inOwner.hasOwnProperty( inTarget[ "id" ] ) &&
				inOwner[ inTarget[ "id" ] ] == inTarget )
				return inTarget[ "id" ];

			if( !_cache.hasOwnProperty( inTarget ) )
			{
				var ownerInfo : Type = Type.forType( inOwner );
				var targetInfo : Type = Type.forType( inTarget );

				for each( var f : Field in ownerInfo.getFields() )
				{
					if( f.fullAccess && f.scope == Field.SCOPE_PUBLIC && inOwner[ f.name ] == inTarget )
					{
						_cache[ inTarget ] = f.name
					}
				}
			}
			return _cache[ inTarget ] as String;
		}

		private static function switchBindings( inOwner : Object, inTarget : Object, inEnable : Boolean, inProperty : String = null ) : void
		{
			var bindingManager : Object = getDefinitionByName( "mx.binding.BindingManager" );
			var theId : String = getId( inOwner, inTarget );

			if( !theId )
				return;
			var targetInfo : Type = Type.forType( inTarget );
			var fields : Vector.<Field> =
				inProperty != null ?
				Vector.<Field>( [ targetInfo.getField( inProperty ) ] ) :
				targetInfo.getFields();

			for each( var field : Field in fields )
			{
				if( ( field.writeOnly || field.fullAccess ) && field.scope == Field.SCOPE_PUBLIC )
				{
					bindingManager.enableBindings( inOwner, theId + "." + field.name, inEnable );

					if( inEnable )
						bindingManager.executeBindings( inOwner, theId + "." + field.name, inTarget );
				}
			}
		}
	}
}
