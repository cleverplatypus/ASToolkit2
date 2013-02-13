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
package org.astoolkit.commons.reflection
{

	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;

	import org.astoolkit.commons.io.data.api.IDataProvider;
	import org.astoolkit.commons.utils.ObjectCompare;
	import org.astoolkit.commons.utils.getLogger;
	import org.astoolkit.commons.utils.isVector;
	import org.astoolkit.commons.configuration.api.ISelfWiring;

	public final class AutoConfigUtil
	{
		private static const LOGGER : ILogger = getLogger( AutoConfigUtil );

		//TODO: implement inheritance-tree-safe auto-config fields assignment to best match target fields
		// 		implement support for IComponent.pid (pid marked children can be assigned even to 
		//		fields with no [AutoConfig] annotation)
		public static function autoConfig(
			inTarget : ISelfWiring,
			inChildren : Array ) : Vector.<PropertyDataProviderInfo>
		{
			if( inChildren == null || inChildren.length == 0 )
				return null;
			var deferredConfigs : Vector.<PropertyDataProviderInfo> = new Vector.<PropertyDataProviderInfo>();
			var autoConfigFields : Vector.<Field> =
				Type.forType( inTarget )
				.getFieldsWithAnnotation( AutoConfig );
			autoConfigFields = autoConfigFields.sort(
				function( inA : Field, inB : Field ) : int
				{
					//TODO: handle multiple [AutoConfig] annotations
					var aAnnotation : AutoConfig = AutoConfig( inA.getAnnotationsOfType( AutoConfig )[ 0 ] );
					var bAnnotation : AutoConfig = AutoConfig( inB.getAnnotationsOfType( AutoConfig )[ 0 ] );
					var aType : Class = aAnnotation.match != null ? aAnnotation.match : inA.type;
					var bType : Class = bAnnotation.match != null ? bAnnotation.match : inB.type;
					if( aType === Object )
						return 1;
					if( bType === Object )
						return -1
					if( aType != bType )
						return ObjectCompare.compare(
							getQualifiedClassName( aType ),
							getQualifiedClassName( bType ) );
					else
						return ObjectCompare.compare(
							aAnnotation.order,
							bAnnotation.order );
				} );
			var childrenInfo : Array = inChildren.map(
				function( inItem : Object, inIndex : int, inArray : Array ) : Object
				{
					return {
							assigned: false,
							object: inItem
						};
				} );
			var child : Object;
			var collectionsInfo : Object = {};

			for each( var f : Field in autoConfigFields )
			{
				for each( child in childrenInfo )
				{
					if( child.assigned )
						continue;

					if( isVector( f.type ) && child.object is f.subtype )
					{
						if( !collectionsInfo.hasOwnProperty( f.name ) )
						{
							collectionsInfo[ f.name ] = new ( f.type )();
							inTarget[ f.name ] = collectionsInfo[ f.name ];
						}
						collectionsInfo[ f.name ].push( child.object );
						child.name = f.name;
						child.assigned = true;
						continue;
					}
					var annotations : Vector.<IAnnotation> = f.getAnnotationsOfType( AutoConfig );
					var annotation : AutoConfig = annotations != null && annotations.length > 0 ?
						annotations[ 0 ] as AutoConfig : null;
					var type : Class = annotation.match ? annotation.match : f.type;

					if( child.object is type )
					{
						inTarget[ f.name ] = child.object;
						child.name = f.name;
						child.assigned = true;
						break;
					}

					if( child.object is IDataProvider &&
						IDataProvider( child.object ).providedType == type )
					{
						deferredConfigs.push(
							PropertyDataProviderInfo.create(
							f.name,
							child.object as IDataProvider ) );
						child.name = f.name;
						child.assigned = true;
						break;
					}
				}
			}
			return deferredConfigs;
		}

		/**
		 * Processes <code>IDataProvider</code> descriptors on the target object.
		 * This is usually called repeteadly before the target object consumes
		 * its properties and allows changes in the data provider settings
		 * to be reflected in the target object configuration
		 */
		public static function processDataProviders( inTarget : Object, inConfig : Vector.<PropertyDataProviderInfo> ) : void
		{
			for each( var propConfig : PropertyDataProviderInfo in inConfig )
			{
				inTarget[ propConfig.name ] = propConfig.dataProvider.getData();
			}
		}
	}
}
