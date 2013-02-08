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
package org.astoolkit.workflow.task.io.filestream
{

	import flash.filesystem.FileStream;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Closes a <code>flash.filesystem.FileStream</code>.<br><br>
	 *
	 * <b>Input</b>
	 * <ul>
	 * <li>a <code>flash.filesystem.FileStream</code> object</li>
	 * </ul>
	 * <b>No Output</b>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>stream</code> (injectable): a target FileStream</li>
	 * </ul>
	 * </p>
	 */
	public class CloseStream extends BaseTask
	{

		private var _stream : FileStream;

		[InjectPipeline]
		public function set stream( inValue :FileStream) : void
		{
			_onPropertySet( "stream" );
			_stream = inValue;
		}

		override public function begin() : void
		{
			super.begin();

			if( _stream )
				_stream.close();
			complete();
		}
	}
}
