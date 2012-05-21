package org.astoolkit.commons.collection
{
	import org.astoolkit.commons.factory.PooledFactory;
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import org.osmf.metadata.Metadata;
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.collection.api.IIteratorFactory;

	
	public class DefaultIteratorFactory extends PooledFactory implements IIteratorFactory
	{
		private static var _iteratorsMetaCache : Object = {};
		
		private var _registeredIteratorClasses : Vector.<Class>;
		
		public function DefaultIteratorFactory()
		{
			super();
			_registeredIteratorClasses = new Vector.<Class>();
			_registeredIteratorClasses.push( ListIterator );
			_registeredIteratorClasses.push( CountIterator );
		}
		
		public function iteratorForSource( inSource : Object, inProperties : Object = null ) : IIterator
		{
			for each( var iteratorType : Class in _registeredIteratorClasses )
			{
				for each( var supportedType : Class in getIteratorSourceTypes( iteratorType ) )
				{
					if( ( inSource == null&&  supportedType == null ) || inSource is supportedType )
						return getInstance( iteratorType, inProperties );
				}
			}
			return null;
		}
		
	
		private static function getIteratorSourceTypes( inObject : Object ) : Array
		{
			var z : String = getQualifiedClassName( Array );
			var cName : String = getQualifiedClassName( inObject ) 
			if( !_iteratorsMetaCache.hasOwnProperty( cName ) )
				_iteratorsMetaCache[ cName ] = {};
			if( !_iteratorsMetaCache[ cName ].hasOwnProperty( "IteratorSource" ) )
			{
				var classInfo : XML = describeType( inObject );
				var metaTag : XMLList = classInfo..metadata.(@name == "IteratorSource");
				if( metaTag.length() > 0 )
				{
					var types : Array = metaTag.arg.@value.toString().replace(/\b/g, "" ).split( "," );
					types = types.map(
						function( inClassName : String, inIndex : int, inArray : Array ) : Class 
						{
							if( inClassName == "Vector" )
								return Vector;
							if( inClassName == "null" )
								return null;
							return getDefinitionByName( inClassName ) as Class;
						} );
					_iteratorsMetaCache[ cName ]["IteratorSource"] = types;
				}
			}
			return _iteratorsMetaCache[ cName ]["IteratorSource"] as Array;
		}
	}
}