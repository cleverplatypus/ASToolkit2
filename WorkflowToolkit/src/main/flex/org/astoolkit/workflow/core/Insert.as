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
	
	import org.astoolkit.workflow.api.*;
	
	[DefaultProperty( "elements" )]
	/**
	 * An entry for the <code>IElementsGroup</code>'s insert list.
	 *
	 * @see org.astoolkit.workflow.core.IElementsGroup#insert
	 */
	public final class Insert
	{
		public static const AFTER : String = "after";
		
		public static const BEFORE : String = "before";
		
		public static const REPLACE : String = "replace";
		
		/**
		 * the elements to insert
		 */
		public var elements : Vector.<IWorkflowElement>;
		
		[Inspectable( enumeration="before,after,replace" )]
		/**
		 * insertion mode: either <code>after</code>, <code>before</code> or <code>replace</code>
		 */
		public var mode : String = BEFORE;
		
		/**
		 * the group into which <code>elements</code> will be inserted
		 */
		public var parent : IElementsGroup;
		
		/**
		 * (optional) the element the <code>mode</code> property refers to
		 */
		public var relativeTo : IWorkflowElement;
	}
}
