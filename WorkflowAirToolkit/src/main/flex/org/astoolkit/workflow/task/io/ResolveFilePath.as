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
package org.astoolkit.workflow.task.io
{

	import flash.filesystem.File;
	import org.astoolkit.workflow.core.BaseTask;

	public class ResolveFilePath extends BaseTask
	{

		private var _sourceFile : File;

		public var path : String;

		[InjectPipeline]
		public function set sourceFile( inValue :File) : void
		{
			_onPropertySet( "sourceFile" );
			_sourceFile = inValue;
		}

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !_sourceFile )
			{
				fail( "sourceFile is not set" );
				return;
			}
			complete( _sourceFile.resolvePath( path ) );
		}
	}
}
