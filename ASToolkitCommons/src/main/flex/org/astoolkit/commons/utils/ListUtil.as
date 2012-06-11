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
package org.astoolkit.commons.utils
{

	import flash.utils.getQualifiedClassName;
	import mx.collections.IList;

	/**
	 * Utility static class to convert between two list types
	 */
	public final class ListUtil
	{
		/**
		 * converts between two list types.
		 * <p>Supported lists are Array, Vector.&lt;ANY&gt;, IList</p>
		 *
		 * @param inSource the source list
		 * @param inDestinationClass (optional) the destination list type
		 */
		public static function convert( inSource : Object, inDestinationClass : Class = null ) : Object
		{
			if( !inDestinationClass )
				inDestinationClass = Array;

			if( !inSource ||
				( !( inSource is Array ) &&
				!getQualifiedClassName( inSource ).match( /^__AS3__\.vec::Vector\.<.+>$/ ) &&
				!( inSource is IList ) ) )
			{
				throw new Error( "No suitable inSource list provided" );
			}

			if( ( !( inDestinationClass === Array ) &&
				!getQualifiedClassName( inDestinationClass ).match( /^__AS3__\.vec::Vector\.<.+>$/ ) &&
				!( inDestinationClass is IList ) ) )
			{
				throw new Error( "No supported inDestinationClass provided" );
			}
			var out : * = new inDestinationClass();

			for each( var item : * in inSource )
			{
				if( out is Array || getQualifiedClassName( out ).match( /^__AS3__\.vec::Vector\.<.+>$/ ) )
					out.push( item );
				else if( out is IList )
					out.addItem( item );
			}
			return out;
		}
	}
}
