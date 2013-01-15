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
package org.astoolkit.commons.reflection
{

	import org.astoolkit.commons.io.data.api.IDataProvider;

	public class PropertyDataProviderInfo
	{

		public static function create( 
			inName : String, 
			inDataProvider : IDataProvider ) : PropertyDataProviderInfo
		{
			var out : PropertyDataProviderInfo = new PropertyDataProviderInfo();
			out._name = inName;
			out._dataProvider = inDataProvider;
			return out;
		}

		private var _dataProvider : IDataProvider;

		private var _name : String;

		public function get dataProvider() : IDataProvider
		{
			return _dataProvider;
		}

		public function get name() : String
		{
			return _name;
		}
	}
}