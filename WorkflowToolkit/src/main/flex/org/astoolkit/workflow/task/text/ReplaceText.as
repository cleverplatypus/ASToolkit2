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

	import org.astoolkit.workflow.core.BaseTask;

	public class ReplaceText extends BaseTask
	{

		private var _text : String;

		private var _regexp : RegExp;

		[AutoAssign]
		public function set regexp( value : RegExp ) : void
		{
			_onPropertySet( "regexp" );
			_regexp = value;
		}


		private var _replacement : String = "";

		[AutoAssign]
		public function set replacement( value : String ) : void
		{
			_onPropertySet( "replacement" );
			_replacement = value;
		}


		[InjectPipeline]
		public function set text( inValue : String ) : void
		{
			_onPropertySet( "text" );
			_text = inValue;
		}

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !_text )
			{
				fail( "Text not provided" );
				return;
			}

			if( !_regexp )
			{
				fail( "Regexp not provided" );
				return;
			}

			complete( _text.replace( _regexp, _replacement ) );
		}
	}
}
