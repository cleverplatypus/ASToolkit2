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
package org.astoolkit.workflow.task.api
{

	[Bindable]
	[Template]
	/**
	 * Template for a task that shows an object's structure
	 * optionally suspending the workflow execution.
	 * <p>Implementations could show a window with
	 * the object's outline tree or dump the provided data
	 * in any format for auditing.</p>
	 */
	public interface IInspectObject
	{
		function set object( inValue : Object ) : void;
		function set pause( inValue : Boolean ) : void;
	}
}
