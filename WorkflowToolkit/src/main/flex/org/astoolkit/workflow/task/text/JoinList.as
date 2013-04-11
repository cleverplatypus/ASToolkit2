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

	import mx.collections.IList;

	import org.astoolkit.lang.util.isCollection;
	import org.astoolkit.workflow.core.BaseTask;

	public class JoinList extends BaseTask
	{
		private var _source : Object;

		private var _separator : String;

		public function set separator( value : String ) : void
		{
			_onPropertySet( "separator" );
			_separator = value;
		}

		[InjectPipeline]
		[AutoAssign]
		public function set source( value : Object ) : void
		{
			_onPropertySet( "source" );
			_source = value;
		}

		override public function begin() : void
		{
			super.begin();

			if( !isCollection( _source ) )
			{
				fail( "No input list provided" );
				return;
			}
			var joinable : Object =
				_source is IList ? _source.toArray() : _source;
			complete( joinable.join( _separator ? _separator : "" ) );
		}
	}
}
