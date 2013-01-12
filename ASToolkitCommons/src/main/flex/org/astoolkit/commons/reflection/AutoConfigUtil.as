package org.astoolkit.commons.reflection
{

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.object_proxy;
	import org.astoolkit.commons.io.data.api.IDataProvider;
	import org.astoolkit.commons.utils.ObjectCompare;
	import org.astoolkit.commons.wfml.IAutoConfigContainerObject;

	public final class AutoConfigUtil
	{
		private static const LOGGER : ILogger = getLogger( AutoConfigUtil );

		//TODO: implement inheritance-tree-safe auto-config fields assignment to best match target fields
		//TODO: implement support for IComponent.pid
		public static function autoConfig( 
			inTarget : IAutoConfigContainerObject, 
			inChildren : Array ) : Vector.<PropertyDataProviderInfo>
		{
			if( inChildren == null || inChildren.length == 0 )
				return null;
			var deferredConfigs : Vector.<PropertyDataProviderInfo> = new Vector.<PropertyDataProviderInfo>();
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
						child.name = f.name;
						child.assigned = true;
						continue;
					}
					var annotations : Vector.<IAnnotation> = f.getAnnotationsOfType( AutoConfig );
					var annotation : AutoConfig = annotations != null && annotations.length > 0 ?
						annotations[0] as AutoConfig : null;
					var type : Class = annotation.type ? annotation.type : f.type;

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
	}
}
