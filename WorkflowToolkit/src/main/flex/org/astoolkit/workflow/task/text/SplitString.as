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

	public class SplitString extends BaseTask
	{
		private var _source : String;

		private var _delimiter : Object;

		[InjectPipeline]
		[AutoAssign]
		public function set source( inValue : String ) : void
		{
			_onPropertySet( "source" );
			_source = inValue;
		}

		public function set delimiter( inValue : Object ) : void
		{
			_onPropertySet( "delimiter" );
			_delimiter = inValue;
		}

		override public function begin() : void
		{
			super.begin();

			if( !_source )
			{
				fail( "No source provided" );
				return;
			}
			complete( _source.split( _delimiter ) );
		}
	}
}
