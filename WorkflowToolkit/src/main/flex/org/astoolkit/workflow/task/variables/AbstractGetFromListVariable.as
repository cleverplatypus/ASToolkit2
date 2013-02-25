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

	import org.astoolkit.commons.utils.isCollection;
	import org.astoolkit.commons.utils.isVector;
	import org.astoolkit.workflow.constant.UNDEFINED;
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.internals.GroupUtil;

	internal class AbstractGetFromListVariable extends BaseTask
	{

		[Inspectable( enumeration = "lastIteration,fail,break,returnNull", defaultValue = "fail" )]
		public var emptyListPolicy : String = "fail";

		/**
		 * @private
		 */
		private var _name : String;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !_name || _name == "" )
			{
				fail( "Variable name not provided" );
				return;
			}

			if( !context.variables.variableIsDefined( _name ) )
			{
				fail( "Variable {0} doesn't exist", _name );
				return;
			}
			var varInstance : * = context.variables[ _name ];

			if( !isCollection( varInstance ) )
			{
				fail( "Attempt to pop data from an unknown list type" );
				return;
			}
			var out : * = getValue( varInstance );



			if( out !== undefined )
				complete( out );
			else
			{
				if( emptyListPolicy == "fail" ||
					_currentIterator == null )
				{
					fail( "Destination list is empty" );
					return;
				}
				else if( _currentIterator != null && emptyListPolicy == "lastIteration" )
					_currentIterator.abort();
				else if( emptyListPolicy == "break" )
					GroupUtil.getParentWorkflow( this ).abort();
				else if( emptyListPolicy == "returnNull" )
					complete( null );
			}
		}

		protected function getValue( inList : Object ) : *
		{
			throw new Error( "getFromList not implemented in abstract " +
				"class AbstractRemoveFromVariableList" );
		}

		public function set name( inValue : String ) : void
		{
			if( inValue )
				_name = inValue.match( /^\$/ ) ? inValue : "$" + inValue;
			else
				_name = null;
		}
	}
}
