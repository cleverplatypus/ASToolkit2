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
package org.astoolkit.workflow.annotation
{

	import flash.utils.getDefinitionByName;
	import org.astoolkit.lang.reflection.Metadata;

	[Metadata( name="TaskInput", target="field" )]
	[MetaArg( name="types", target="class" )]
	public class TaskInput extends Metadata
	{
		private var _types : Vector.<Class>;

		public function get types() : Vector.<Class>
		{
			if( !_types )
				_types = Vector.<Class>( getArray( "types", true ).map(
					function( inClassName : String, inIndex : int, inArray : Array ) : Class
					{
						if( inClassName == "Vector" || inClassName.match( /^Vector\.<.+>$/ ) )
							inClassName = "__AS3__.vec::" + inClassName;
						return getDefinitionByName( inClassName ) as Class;
					} ) );
			return _types;
		}
	}
}
