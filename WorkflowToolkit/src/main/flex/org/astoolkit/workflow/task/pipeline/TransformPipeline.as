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
package org.astoolkit.workflow.task.pipeline
{
	import org.astoolkit.workflow.core.BaseTask;
	
	import flash.events.Event;
	
	[Event(name="transform", type="org.astoolkit.workflow.task.pipeline.TransformPipelineEvent")]
	public class TransformPipeline extends BaseTask
	{
		override public function begin() : void
		{
			super.begin();
			var out : *;
			if( hasEventListener( TransformPipelineEvent.TRANSFORM ) )
			{
				var e : TransformPipelineEvent = new TransformPipelineEvent( filteredInput );
				dispatchEvent( e );
				out = e.pipelineData;
			}
			else
			{
				//apply filters
				out = filteredInput;
			}
			complete( out );
		}
	}
}