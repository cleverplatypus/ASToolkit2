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
package org.astoolkit.commons.wfml.autoassign
{

	import flash.utils.getQualifiedClassName;

	import mx.core.ClassFactory;
	import mx.logging.ILogger;
	import mx.utils.object_proxy;

	import org.astoolkit.commons.configuration.api.ISelfWiring;
	import org.astoolkit.commons.io.data.api.IDataBuilder;
	import org.astoolkit.commons.utils.ObjectCompare;
	import org.astoolkit.commons.wfml.api.IComponent;
	import org.astoolkit.lang.reflection.AnnotationUtil;
	import org.astoolkit.lang.reflection.Field;
	import org.astoolkit.lang.reflection.api.IAnnotation;
	import org.astoolkit.lang.reflection.Type;
	import org.astoolkit.lang.util.getLogger;
	import org.astoolkit.lang.util.isVector;

	public final class AutoAssignUtil
	{
		private static const LOGGER : ILogger = getLogger( AutoAssignUtil );

		private static var collectionsInfo : Object = {};

		private static const ANNOTATIONS_INITIALIZED : Boolean = (
			function() : Boolean
			{
				AnnotationUtil.registerAnnotation( new ClassFactory( AutoAssign ) );
				return true;
			} )();

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
			var pidded : Vector.<PropertyInfo> = new Vector.<PropertyInfo>();
			var unpidded : Vector.<PropertyInfo> = new Vector.<PropertyInfo>();
			var child : PropertyInfo;

			for each( child in childrenInfo )
			{
				if( child.object is IComponent && IComponent( child.object ).pid )
					pidded.push( child );
				else
					unpidded.push( child );
			}
			collectionsInfo[ inTarget ] = {};

			var assignedFields : Object = {};

			var f : Field;
			var deferred : PropertyDataBuilderInfo;



			for each( f in autoConfigFields )
			{
				for each( child in pidded )
				{
					if( child.assigned )
						continue;

					if( IComponent( child.object ).pid == f.name )
					{
						deferred = processPidded( child, f, inTarget );

						if( deferred )
							deferredConfigs.push( deferred );
					}
				}
			}

			for each( f in autoConfigFields )
			{
				for each( child in unpidded )
				{
					if( child.assigned )
						continue;
					deferred = processUnpidded( child, f, inTarget );

					if( deferred )
						deferredConfigs.push( deferred );
				}
			}
			delete collectionsInfo[ inTarget ];
			return deferredConfigs;
		}

		private static function processPidded( inInfo : PropertyInfo, inField : Field, inTarget : Object ) : PropertyDataBuilderInfo
		{
			var deferred : PropertyDataBuilderInfo;

			if( !( inInfo.object is IDataBuilder ) ||
				( inField.type && Type.forType( inField.type ).implementsInterface( IDataBuilder ) ) )
			{
				inTarget[ IComponent( inInfo.object ).pid ] = inInfo.object;
			}
			else if( inField.type && isVector( inField.type ) &&
				Type.forType( Type.forType( inField.type ).subtype ).implementsInterface( IDataBuilder ) )
			{
				if( inTarget[ inField.name ] == null )
					inTarget[ inField.name ] = new ( inField.type )();
				inTarget[ inField.name ].push( inInfo.object );
			}
			else
			{
				deferred =
					PropertyDataBuilderInfo.create(
					inField.name,
					inInfo.object as IDataBuilder );
			}
			inInfo.name = inField.name;
			inInfo.assigned = true;
			return deferred;
		}


		private static function processUnpidded( inInfo : PropertyInfo, inField : Field , inTarget : Object) : PropertyDataBuilderInfo
		{
			var annotations : Vector.<IAnnotation> = inField.getAnnotationsOfType( AutoAssign );
			var annotation : AutoAssign = annotations != null && annotations.length > 0 ?
				annotations[ 0 ] as AutoAssign : null;
			var type : Class = annotation.match ? annotation.match : inField.type;

			var deferred : PropertyDataBuilderInfo;

			if( type && inInfo.object is type )
			{
				inTarget[ inField.name ] = inInfo.object;
				inInfo.name = inField.name;
				inInfo.assigned = true;
				return null;
			}

			if( isVector( inField.type ) && inInfo.object is Type.forType( inField.type ).subtype )
			{
				if( !collectionsInfo[ inTarget ].hasOwnProperty( inField.name ) )
				{
					collectionsInfo[ inTarget ][ inField.name ] = new ( inField.type )();
					inTarget[ inField.name ] = collectionsInfo[ inTarget ][ inField.name ];
				}
				collectionsInfo[ inTarget ][ inField.name ].push( inInfo.object );
				inInfo.name = inField.name;
				inInfo.assigned = true;
				return null;
			}

			if( inInfo.object is IDataBuilder &&
				( ( inInfo.object is IComponent && inField.name == IComponent( inInfo.object ).pid ) ||
				( type && IDataBuilder( inInfo.object ).builtDataType == type ) ) )
			{
				deferred =
					PropertyDataBuilderInfo.create(
					inField.name,
					inInfo.object as IDataBuilder  );
				inInfo.name = inField.name;
				inInfo.assigned = true;
				return deferred;
			}
			return null;
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
