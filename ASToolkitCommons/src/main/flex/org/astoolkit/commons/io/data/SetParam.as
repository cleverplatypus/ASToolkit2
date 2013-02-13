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

	import org.astoolkit.commons.eval.Resolve;
	import org.astoolkit.commons.io.data.api.IDataBuilder;
	import org.astoolkit.commons.process.api.IDeferrableProcess;

	public class SetParam extends Resolve implements IDataBuilder, IDeferrableProcess
	{
		private var _deferredExecutionWatchers:Vector.<Function>;

		private var _type : Class = Object;

		public function get builtDataType() : Class
		{
			return _type;
		}

		public function set type(value:Class) : void
		{
			_type = value;
		}

		public function addDeferredProcessWatcher( inWatcher : Function ) : void
		{
			if( !_deferredExecutionWatchers )
				_deferredExecutionWatchers = new Vector.<Function>();
			_deferredExecutionWatchers.push( inWatcher );
		}

		public function getData() : *
		{
			return resolve( null, _document).result;
		}

		public function isProcessDeferred() : Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
	}
}
