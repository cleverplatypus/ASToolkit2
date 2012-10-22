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

	import mx.core.IFactory;
	import org.astoolkit.workflow.api.IWorkflowTask;

	[Bindable]
	[Template]
	/**
	 * Template interface for tasks that show a UI dialog with a title,
	 * a text, a YES/OK button and optional NO and Cancel buttons.
	 * <p>The task should output <code>true</code> when YES/OK is pressed,
	 * <code>false</code> if NO is pressed and fail with "user canceled" status code
	 * if CANCEL is pressed.</p>
	 * <p>Implementations are responsible for the look and feel of the dialog,
	 * optionally according to the CSS <code>styleName</code> and a
	 * <code>skinClass</code> parameters.</p>
	 */
	public interface IShowSimpleDecisionDialog
	{
		function set cancelButton( inValue : Boolean ) : void;
		function set modal( inValue : Boolean ) : void;
		function set noButton( inValue : Boolean ) : void;
		function set skinClass( inValue : IFactory ) : void;
		function set styleName( inValue : String ) : void;
		function set text( inValue : String ) : void;
		function set title( inValue : String ) : void;
	}
}
