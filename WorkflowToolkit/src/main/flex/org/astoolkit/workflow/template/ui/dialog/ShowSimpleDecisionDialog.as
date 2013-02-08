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
package org.astoolkit.workflow.template.ui.dialog
{

	import mx.core.IFactory;
	import org.astoolkit.workflow.core.BaseTaskTemplate;
	import org.astoolkit.workflow.core.ExitStatus;
	import org.astoolkit.workflow.task.api.IShowSimpleDecisionDialog;

	public dynamic class ShowSimpleDecisionDialog extends BaseTaskTemplate implements IShowSimpleDecisionDialog
	{
		public static const NO : String  = "no";

		public static const YES : String  = "yes";

		public function set cancelButton( inValue : Boolean ) : void
		{
			setImplementationProperty( "cancelButton", inValue );
		}

		public function set modal( inValue : Boolean ) : void
		{
			setImplementationProperty( "modal", inValue );
		}

		public function set noButton( inValue : Boolean ) : void
		{
			setImplementationProperty( "noButton", inValue );
		}

		public function set skinClass( inValue : IFactory ) : void
		{
			setImplementationProperty( "skinClass", inValue );
		}

		public function set styleName( inValue : String ) : void
		{
			setImplementationProperty( "styleName", inValue );
		}

		public function set text( inValue : String ) : void
		{
			setImplementationProperty( "text", inValue );
		}

		public function set title( inValue : String ) : void
		{
			setImplementationProperty( "title", inValue );
		}

		public function set yesButton( inValue : Boolean ) : void
		{
			setImplementationProperty( "yesButton", inValue );
		}
	}
}
