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
package org.astoolkit.workflow.core
{
	import org.astoolkit.workflow.api.ISwitchCase;
	import org.astoolkit.workflow.api.IWorkflowElement;

	[DefaultProperty("children")]
	/**
	 * The <code>default</code> case block for a <code>Switch</code> group.
	 * <p>Its children are enabled if none of the <code>Case</code> groups are.</p>
	 */
	public class Default extends Group implements ISwitchCase
	{
		
		/**
		 * @private
		 */
		public function switchChildren( inEnabled : Boolean ) : void
		{
			if( _children )
			{
				for each( var element : IWorkflowElement in _children )
				{
					element.enabled = inEnabled;
				}
			}
		}
		
	}
}