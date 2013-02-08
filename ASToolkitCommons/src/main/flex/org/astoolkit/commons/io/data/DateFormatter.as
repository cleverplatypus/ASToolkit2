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
package org.astoolkit.commons.io.data
{

	import org.astoolkit.commons.io.data.api.IDataProvider;
	import org.astoolkit.commons.process.api.IDeferrableProcess;
	import org.astoolkit.commons.wfml.IAutoConfigurable;
	import org.astoolkit.commons.wfml.IComponent;

	[DefaultProperty("autoConfigChildren")]
	public class DateFormatter implements IDataProvider, IComponent, IAutoConfigurable, IDeferrableProcess
	{
		private var _format : String;

		private var _sourceText:String;

		public function set autoConfigChildren(inValue:Array) : void
		{
			// TODO Auto Generated method stub

		}

		public function set format(value:String) : void
		{
			_format = value;
		}

		public function get pid() : String
		{
			return null;
		}

		public function set pid(inValue:String) : void
		{
		}

		public function get providedType() : Class
		{
			return null;
		}

		[AutoConfig]
		public function set sourceText( inValue : String ) : void
		{
			_sourceText = inValue;
		}

		public function addDeferredProcessWatcher(inWatcher:Function) : void
		{
			// TODO Auto Generated method stub

		}

		public function getData() : *
		{
			return null;
		}

		public function initialized(document:Object, id:String) : void
		{
			// TODO Auto Generated method stub

		}

		public function isProcessDeferred() : Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
	}
}
