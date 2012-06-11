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
package org.astoolkit.workflow.task.misc
{

	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Sets an object's property value.
	 * <p>
	 * <b>Input</b>
	 * <ul>
	 * <li>any value</li>
	 * </ul>
	 * </p>
	 * <p>
	 * <b>No output</b>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>value</code> (injectable): any value</li>
	 * <li><code>property</code>: the target's property name</li>
	 * <li><code>target</code>: the object to which to set the <code>property</code>.
	 * Defaults to the current document</li>
	 * </ul>
	 * </p>
	 * @example Setting the current workflow document's property value.
	 * 			<p>In the following example, <code>SendMessage</code>
	 * 			gets some data and passes it via pipeline to <code>SetProperty</code>.</p>
	 * 			<p>Since only the <code>property</code> param is set, <code>SetProperty</code>
	 * 			tries to assign the current pipeline data to <code>document.aString</code></p>
	 *
	 * <listing version="3.0">
	 * &lt;msg:SendMessage
	 *     message=&quot;{ GetSomeString }&quot;
	 *     /&gt;
	 * &lt;misc:SetProperty
	 *     property="aString"
	 *     /&gt;
	 * </listing>
	 */
	public class SetProperty extends BaseTask
	{
		/**
		 * the target's property name
		 */
		public var property : String;

		/**
		 * the object to which to set the <code>property</code>.
	   * Defaults to the current document
				  */
		public var target : Object;

		[Bindable]
		[InjectPipeline]
		/**
		 * any value to be set to <code>target[ property ]</code>
		 */
		public var value : *;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !target )
				target = document;

			if( !property || !target.hasOwnProperty( property ) )
			{
				fail( "SetProperty started without a property name or property name not found on target" );
				return;
			}

			if( value != undefined )
				target[ property ] = value;
			complete();
		}
	}
}
