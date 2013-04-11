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
package org.astoolkit.workflow.task.variables
{

	import flash.utils.getQualifiedClassName;

	import mx.collections.IList;

	import org.astoolkit.lang.util.isCollection;
	import org.astoolkit.workflow.core.BaseTask;

	internal class AbstractAddToListVariable extends BaseTask
	{
		public var listType : Class;

		private var _value : *;

		[InjectPipeline]
		[AutoAssign]
		public function set value( value : * ) : void
		{
			_value = value;
		}


		private var _name : String;

		override public function begin() : void
		{
			super.begin();

			if( !_name || _name == "" )
			{
				fail( "Variable name not provided" );
				return;
			}
			var varInstance : *;
			var localValue : Object =
				_value === undefined ? filteredInput : _value;

			if( listType )
			{
				if( !isCollection( listType ) )
				{
					fail( "Attempt to push data to an unknown list type" );
					return;
				}
			}

			if( context.variables.variableIsDefined( _name ) )
			{
				if( listType )
				{
					if( getQualifiedClassName( listType ) != getQualifiedClassName( context.variables[ _name ] ) )
					{
						fail( "Destination list type and listType classes don't match" );
						return;
					}
				}
				varInstance = context.variables[ _name ];
			}

			if( !varInstance )
				varInstance = listType ? new listType() : [];

			if( !context.variables.variableIsDefined( _name ) )
				context.variables[ _name ] = varInstance;

			addValue( varInstance, localValue );
			complete();
		}

		protected function addValue( inList : Object, inValue : Object ) : void
		{
			throw new Error( "addValue not implemented in abstract " +
				"class AbstractAddToVariableList" );
		}

		public function set name( inValue : String ) : void
		{
			_onPropertySet( "name" );

			if( inValue )
				_name = inValue.match( /^\$/ ) ? inValue : "$" + inValue;
			else
				_name = null;
		}
	}
}
