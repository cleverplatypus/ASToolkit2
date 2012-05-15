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

package org.astoolkit.workflow.task.log
{
	import flash.utils.setInterval;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.ObjectUtil;
	
	import org.astoolkit.workflow.core.BaseTask;
	
	/**
	 * Prints on the console.
	 * <p>If <code>text</code> is not set this task
	 * dumps the pipeline data object (after filtering) with ObjectUtil.toString()</p>
	 */
	public class Trace extends BaseTask
	{
		
		private var _text : String;

		/**
		 * the text to output to console. If omitted, the pipeline data is used.
		 */
		public function set text( inText : String ) : void
		{
			_text = inText;
		}
		
		public function get text() : String
		{
			return _text;
		}
			
		
		override public function begin() : void
		{
			super.begin();
			var outText : String = text;
			if( outText == null ) 
				outText = ObjectUtil.toString( filteredPipelineData );
			trace( outText );
			complete();
		}
		
	}
}