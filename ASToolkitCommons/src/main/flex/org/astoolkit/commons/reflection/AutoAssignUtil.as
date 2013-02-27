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
	import mx.utils.object_proxy;

	import org.astoolkit.commons.configuration.api.ISelfWiring;
	import org.astoolkit.commons.io.data.api.IDataBuilder;
	import org.astoolkit.commons.utils.ObjectCompare;
	import org.astoolkit.commons.utils.getClass;
	import org.astoolkit.commons.utils.getLogger;
	import org.astoolkit.commons.utils.isVector;
	import org.astoolkit.commons.wfml.api.IComponent;

	public final class AutoAssignUtil
	{
		private static const LOGGER : ILogger = getLogger( AutoAssignUtil );

		//TODO: implement inheritance-tree-safe auto-config fields assignment to best match target fields
		public static function autoAssign(
			inTarget : ISelfWiring,
			inChildren : Array ) : Vector.<PropertyDataBuilderInfo>
		{
			if( inChildren == null || inChildren.length == 0 )
				return null;
			var deferredConfigs : Vector.<PropertyDataBuilderInfo> = new Vector.<PropertyDataBuilderInfo>();
			var autoConfigFields : Vector.<Field> =
				Type.forType( inTarget )
				.getFieldsWithAnnotation( AutoAssign );
			autoConfigFields = autoConfigFields.sort(
				function( inA : Field, inB : Field ) : int
				{
					//TODO: handle multiple [AutoAssign] annotations
					var aAnnotation : AutoAssign = AutoAssign( inA.getAnnotationsOfType( AutoAssign )[ 0 ] );
					var bAnnotation : AutoAssign = AutoAssign( inB.getAnnotationsOfType( AutoAssign )[ 0 ] );
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

			var childrenInfo : Vector.<PropertyInfo> = Vector.<PropertyInfo>(inChildren.map(
				function( inItem : Object, inIndex : int, inArray : Array ) : Object
				{
					return new PropertyInfo( inItem );
				} ) );
			var child : PropertyInfo;
			var collectionsInfo : Object = {};

			for each( var f : Field in autoConfigFields )
			{
				for each( var processPid : Boolean in[ true, false ] )
				{
					for each( child in childrenInfo )
					{
						trace( "******* ",
							getQualifiedClassName( inTarget ),
							" : ", f.name,
							" -> ", getQualifiedClassName( child ),
							" pid: ", processPid );

						if( processPid && ( !( child.object is IComponent ) || !IComponent( child.object ).pid ) )
							continue;

						if( !processPid && child.object is IComponent && IComponent( child.object ).pid )
							continue;

						if( child.assigned )
							continue;
						trace( "processing...");

						if( processPid )
						{
							if( IComponent( child.object ).pid == f.name )
							{
								if( !( child.object is IDataBuilder ) ||
									( f.type && Type.forType( f.type ).implementsInterface( IDataBuilder ) ) )
								{
									inTarget[ IComponent( child.object ).pid ] = child.object;
								}
								else if( f.type && isVector( f.type ) &&
									Type.forType( f.subtype ).implementsInterface( IDataBuilder ) )
								{
									if( inTarget[ f.name ] == null )
										inTarget[ f.name ] = new ( f.type )();
									inTarget[ f.name ].push( child.object );
									child.object.assigned = true;
								}
								else
								{
									deferredConfigs.push(
										PropertyDataBuilderInfo.create(
										f.name,
										child.object as IDataBuilder ) );
								}
								child.name = f.name;
								child.assigned = true;
							}
						}
						else
						{
							var annotations : Vector.<IAnnotation> = f.getAnnotationsOfType( AutoAssign );
							var annotation : AutoAssign = annotations != null && annotations.length > 0 ?
								annotations[ 0 ] as AutoAssign : null;
							var type : Class = annotation.match ? annotation.match : f.type;


							if( type && child.object is type )
							{
								inTarget[ f.name ] = child.object;
								child.name = f.name;
								child.assigned = true;
								break;
							}

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

							if( child.object is IDataBuilder &&
								( ( child.object is IComponent && f.name == IComponent( child.object ).pid ) ||
								( type && IDataBuilder( child.object ).builtDataType == type ) ) )
							{
								deferredConfigs.push(
									PropertyDataBuilderInfo.create(
									f.name,
									child.object as IDataBuilder ) );
								child.name = f.name;
								child.assigned = true;
								break;
							}
						}
					}
				}
			}
			return deferredConfigs;
		}

		/**
		 * Processes <code>IDataBuilder</code> descriptors on the target object.
		 * This is usually called repeteadly before the target object consumes
		 * its properties and allows changes in the data provider settings
		 * to be reflected in the target object configuration
		 */
		public static function processDataBuilders( inTarget : Object, inConfig : Vector.<PropertyDataBuilderInfo> ) : void
		{
			for each( var propConfig : PropertyDataBuilderInfo in inConfig )
			{
				inTarget[ propConfig.name ] = propConfig.dataProvider.getData();
			}
		}
	}
}

class PropertyInfo
{
	public function PropertyInfo( inObject : Object )
	{
		object = inObject;
	}

	public var object : Object;

	public var name : String;

	public var assigned : Boolean;
}
