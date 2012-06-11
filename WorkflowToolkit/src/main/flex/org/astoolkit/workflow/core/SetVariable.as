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
package org.astoolkit.workflow.core
{

	/**
	 * Sets the value of the current's context variable.
	 * If a value is not specified, it uses the current
	 * pipeline data as value.
	 * <p>If <code>name</code> is not specified a random unique name is created.
	 * This can be useful for variables that need to be found by type</p>
	 * <p>
	 * <b>Any Input</b>
	 * </p>
	 * <p>
	 * <b>No Output</b>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>name</code> (optional): the variable name</li>
	 * <li><code>value</code> (optional): the variable value</li>
	 * </ul>
	 * </p>
	 */
	public class SetVariable extends BaseTask
	{
		/**
		 * @private
		 */
		private var _name : String;

		/**
		 * @private
		 */
		private var _value : *;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();
			var aName : String = _name;

			if( !aName )
			{
				aName = ( new Date().getTime() + Math.random().toString() ).replace( ".", "_" );
			}

			if( _value !== undefined )
				context.variables[ aName ] = _value;
			else
				context.variables[ aName ] = filteredInput;
			complete();
		}

		public function set name( inValue : String ) : void
		{
			if( inValue )
				_name = inValue.replace( /^[\$\.]+/ );
			else
				_name = null;
		}

		public function set value( inValue : * ) : void
		{
			_value = inValue;
		}
	}
}
