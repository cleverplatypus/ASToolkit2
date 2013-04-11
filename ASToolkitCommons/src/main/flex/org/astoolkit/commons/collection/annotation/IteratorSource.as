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
package org.astoolkit.commons.collection.annotation
{

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import org.astoolkit.lang.reflection.Metadata;

	[Metadata( target="class" )]
	[MetaArg( name="types", type="[Class]", mandatory="true" )]
	public class IteratorSource extends Metadata
	{
		public function get types() : Vector.<Class>
		{
			var out : Array = getArray( "types", true );

			if( out )
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
