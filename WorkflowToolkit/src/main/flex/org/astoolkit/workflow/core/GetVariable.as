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
	 * Gets a variable either by name or by type from the context
	 * and outputs it.
	 * <p>
	 * <b>Any Input</b>
	 * </p>
	 * <p>
	 * <b>Output</b>
	 * <ul>
	 * <li>the variable's value</li>
	 * </ul>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>name</code>: the variable's name</li>
	 * <li><code>type</code>: the required type. Optional if <code>name</code> is set</li>
	 * </ul>
	 * </p>
	 * @example Setting the pipeline to a typed variable.
	 * 			<p>If the current scope has a variable
	 * 			of type Vector.&lt;String&gt;, it's output
	 * 			to the pipeline</p>
	 * <listing version="3.0">
	 * &lt;vars:GetVariable
	 *     type=&quot;Vector.&lt;String&gt;&quot; /&gt;
	 * </listing>
	 *
	 * @example copying a variable by name.
	 * <listing version="3.0">
	 * &lt;vars:GetVariable
	 *     name="foundUser"
	 *     outlet="$favouriteUser"
	 *     />
	 * </listing>
	 */
	public class GetVariable extends BaseTask
	{
		public var clear : Boolean = false;

		public var defaultValue : *;

		public var type : Class;

		private var _name : String;

		override public function begin() : void
		{
			super.begin();

			if( !_name && !type )
			{
				fail( "No variable name or type provided" );
				return;
			}
			var out : *;
			var localName : String = _name;

			if( !localName )
			{
				var d : * = $.byType( type, true );

				if( d !== undefined )
				{
					localName = d.name;
				}
			}

			if( localName && context.variables.hasOwnProperty( localName ) )
			{
				out = context.variables[ localName ];

				if( clear )
					delete context.variables[ localName ];
			}
			else
				out = defaultValue;
			complete( out );
		}

		public function set name( inValue : String ) : void
		{
			if( inValue )
				_name = inValue.replace( /^[\$\.]+/ );
			else
				_name = null;
		}
	}
}
