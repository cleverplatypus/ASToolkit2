package org.astoolkit.commons.collection.annotation
{
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import org.astoolkit.commons.reflection.Metadata;
	
	[Metadata( target="class" )]
	[MetaArg( name="types", type="[Class]", mandatory="true" )]
	public class IteratorSource extends Metadata
	{
		public function get types() : Vector.<Class>
		{
			var out : Array = getArray( "types", true );
			var s : String = getQualifiedClassName( Vector );
			
			if ( out )
			{
				out = out.map(
					function( inClassName : String, inIndex : int, inArray : Array ) : Class 
					{
						if( inClassName == "Vector" || inClassName.match( /^Vector\.<.+>$/ ) )
							inClassName = "__AS3__.vec::" + inClassName;
						if( inClassName == "null" )
							return null;
						return getDefinitionByName( inClassName ) as Class;
					} );
			}
			return Vector.<Class>( out );
		}
	}
}
