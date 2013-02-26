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
package org.astoolkit.workflow.config
{

	import org.astoolkit.workflow.config.api.IObjectPropertyDefaultValue;

	public class Default implements IObjectPropertyDefaultValue
	{
		private var _property : String;

		private var _targetClass : Class;

		private var _value : *;

		private var _strictClassMatch : Boolean = true;

		public function get strictClassMatch() : Boolean
		{
			return _strictClassMatch;
		}

		public function set strictClassMatch( inValue : Boolean ) : void
		{
			_strictClassMatch = inValue;
		}


		public function get property() : String
		{
			return _property;
		}

		public function set property( value : String ) : void
		{
			_property = value;
		}

		public function get targetClass() : Class
		{
			return _targetClass;
		}

		public function set targetClass( value : Class ) : void
		{
			_targetClass = value;
		}

		public function get value() : *
		{
			return _value;
		}

		public function set value( value : * ) : void
		{
			_value = value;
		}
	}
}
