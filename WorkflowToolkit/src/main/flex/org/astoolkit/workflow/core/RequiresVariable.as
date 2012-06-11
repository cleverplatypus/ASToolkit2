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

	import flash.utils.getQualifiedClassName;
	import mx.events.PropertyChangeEvent;

	/**
	 * Checks the existence of the named/typed variable
	 * in the current scope.
	 * <p>This task can be used at the workflow's root to ensure that all the
	 * required variables are set before proceeding.</p>
	 * <p>The <code>behaviour</code> param determines what to do
	 * if the conditions are not satisfied. If set to <code>auto</code>
	 * the behaviour will be <code>wait</code> if this task is put
	 * at the workflow's root, <code>fail</code> otherwise.</p>
	 * <p>
	 * <b>Any Input</b>
	 * </p>
	 * <p>
	 * <b>Output</b>
	 * <p>if <code>returnValue == true</code> returns the variable's value</p>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>name</code>: the variable name</li>
	 * <li><code>type</code>: the variable type. Optional if <code>name</code> is set</li>
	 * <li><code>behaviour</code>: either <code>fail</code>, <code>wait</code> or <code>auto</code></li>
	 * </ul>
	 * </p>
	 * @example Setting a workflow's variable at startup
	 *
	 * <listing version="3.0">
	 * public function onButtonClick( inEvent : MouseEvent ) : void
	 * {
	 *     var w : EncriptFileWorkflow = new EncriptFileWorkflow();
	 *     w.run();
	 *     w.$.inputFile = _file;
	 * }
	 * </listing>
	 * <listing version="3.0">
	 * &lt;Workflow
	 *     xmlns="org.astoolkit.workflow.core.&#42;"
	 *     &gt;
	 *     &lt;RequiresVariable
	 *         type=&quot;flash.filesystem.File&quot;
	 *         /&gt;
	 *     &lt;crypt:EncriptFile file=&quot;{ $.byType( File ) }&quot;/&gt;
	 * &lt;/Workflow&gt;
	 * </listing>
	 */
	public class RequiresVariable extends BaseTask
	{

		[Inspectable( enumeration="auto,wait,fail", defaultValue="auto" )]
		public var behaviour : String = "auto";

		public var notNull : Boolean;

		public var returnValue : Boolean;

		public var type : Class;

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

			if( _name )
			{
				if( $[ _name ] === undefined )
				{
					onVariableNotAvailable();
					return;
				}
				else
				{
					if( isRightType() )
						complete( returnValue ? $[ _name ] : undefined );
				}
			}
			else if( type is Class )
			{
				var val : * = $.byType( type );

				if( val !== undefined )
					complete( returnValue ? val : undefined );
				else
				{
					onVariableNotAvailable();
					return;
				}
			}
		}

		public function set name( inValue : String ) : void
		{
			if( inValue )
				_name = inValue.replace( /^[\$\.]+/ );
			else
				_name = null;
		}

		/**
		 * @private
		 */
		private function isRightType() : Boolean
		{
			if( !notNull && $[ _name ] == null )
				return true;

			if( type != null && !( $[ _name ] is type ) )
			{
				fail( "Unexpected variable value. Expected '{0}', found '{1}'",
					getQualifiedClassName( type ),
					$[ _name ] == null ? "null" : getQualifiedClassName( $[ _name ] ) );
				return false;
			}
			return true;
		}

		/**
		 * @private
		 */
		private function onVariableNotAvailable() : void
		{
			if( behaviour == "wait" || ( behaviour == "auto" && parent == root ) )
			{
				$.addEventListener(
					PropertyChangeEvent.PROPERTY_CHANGE,
					threadSafe( onVariableProviderChange ) );
				return;
			}
			else
			{
				if( _name )
					fail( "Variable {0} not set", _name );
				else
					fail( "Variable for type {0} not set", getQualifiedClassName( type ) );
			}
		}

		/**
		 * @private
		 */
		private function onVariableProviderChange( inEvent : PropertyChangeEvent ) : void
		{
			if( inEvent.property == _name && isRightType() )
				complete();
		}
	}
}
