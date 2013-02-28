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
package org.astoolkit.workflow.task.text
{

	import org.astoolkit.commons.collection.api.IRepeater;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Takes <code>source</code> and <code>text</code>
	 * and concatenate them.
	 * <p>Both <code>source</code> and <code>text</code>
	 * are defaulted to "".
	 * </p>
	 * <p>
	 * <b>Input</b>
	 * <ul>
	 * <li>a string to be added to <code>source</code></li>
	 * </ul>
	 * </p>
	 * <b>Output</b>
	 * <p>
	 * The concatenated string
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>text</code> (injectable): the text to concatenate</li>
	 * <li><code>source</code> the original string</li>
	 * <li><code>leading</code> if true, <code>text</code> is added at the beginning of <code>source</code></li>
	 * </ul>
	 * </p>
	 */
	public class ConcatString extends BaseTask
	{

		private var _text : String;

		/**
		 * whether to concat the text at the beginning
		 * of the <code>source</code> string
		 */
		public var leading : Boolean;

		/**
		 * the original string
		 */
		public var source : String;

		[InjectPipeline]
		/**
		 * @private
		 */
		public function set text( inValue : String ) : void
		{
			_onPropertySet( "text" );
			_text = inValue;
		}

		override public function begin() : void
		{
			super.begin();
			var theText : String = !_text ? "" : _text;
			var theSource : String = !source ? "" : source;
			complete( leading ? theText + theSource : theSource + theText );
		}
	}
}
