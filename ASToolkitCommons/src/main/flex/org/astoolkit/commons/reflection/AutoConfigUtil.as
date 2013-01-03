package org.astoolkit.commons.reflection
{

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.object_proxy;
	import org.astoolkit.commons.mxml.IAutoConfigContainerObject;
	import org.astoolkit.commons.utils.ObjectCompare;

	public final class AutoConfigUtil
	{
		private static const LOGGER : ILogger = getLogger( AutoConfigUtil );

		//TODO: implement inheritance-tree-safe auto-config fields assignment to best match target fields
		public static function autoConfig( inTarget : IAutoConfigContainerObject, inChildren : Array ) : Array
		{
			var autoConfigFields : Vector.<Field> = 
				Type.forType( inTarget )
				.getFieldsWithAnnotation( AutoConfig );
			autoConfigFields.sort( 
				function( inA : Field, inB : Field ) : int
				{
					var aAnnotation : AutoConfig = AutoConfig( inA.getAnnotationsOfType( AutoConfig )[0] );
					var bAnnotation : AutoConfig = AutoConfig( inB.getAnnotationsOfType( AutoConfig )[0] );
					var aType : Class = aAnnotation.type != null ? aAnnotation.type : inA.type;
					var bType : Class = bAnnotation.type != null ? bAnnotation.type : inB.type;
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
							assigned : false, 
							object : inItem
						};
				} );
			var child : Object;
			var collectionsInfo : Object = {};

			for each( var f : Field in autoConfigFields )
			{
				for each( child in childrenInfo )
				{
					child.name = f.name;

					if( child.assigned )
						continue;

					if( isVector( f.type )  && child.object is f.subtype )
					{
						if( !collectionsInfo.hasOwnProperty( f.name ) )
						{
							collectionsInfo[ f.name ] = new ( f.type )();
							inTarget[ f.name ] = collectionsInfo[ f.name ];
						}
						collectionsInfo[ f.name ].push( child.object );
						child.assigned = true;
						continue;
					}

					if( child.object is f.type )
					{
						inTarget[ f.name ] = child.object;
						child.assigned = true;
						break;
					}
				}
			}
			return childrenInfo;
		}
	}
}
