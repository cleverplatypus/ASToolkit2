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

package org.astoolkit.workflow.task.variables
{
	import org.astoolkit.workflow.core.BaseTask;
	
	/**
	 * Sets the value of the current's context variable.
	 * If a value is not specified, it uses the current 
	 * pipeline data as value
	 */
	public class SetVariable extends BaseTask
	{
		public var name : String;
		public var value : *;
		
		override public function begin() : void
		{
			super.begin();
			if( !name )
			{
				fail( "No variable name provided" );
				return;
			}
			if( value != undefined )
				context.variables[ name ] = value;
			else
				context.variables[ name ] = filteredInput;
			complete();
		}
	}
}