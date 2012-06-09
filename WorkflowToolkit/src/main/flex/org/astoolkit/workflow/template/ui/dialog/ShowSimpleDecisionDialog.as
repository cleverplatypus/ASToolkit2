package org.astoolkit.workflow.template.ui.dialog
{
	import mx.core.IFactory;
	
	import org.astoolkit.workflow.core.BaseTaskTemplate;
	import org.astoolkit.workflow.core.ExitStatus;
	import org.astoolkit.workflow.task.api.IShowSimpleDecisionDialog;
	
	public dynamic class ShowSimpleDecisionDialog extends BaseTaskTemplate implements IShowSimpleDecisionDialog
	{
		public function set yesButton( inValue : Boolean ) : void
		{
			setImplementationProperty( "yesButton", inValue );
		}
		
		public function set noButton( inValue : Boolean ) : void
		{
			setImplementationProperty( "noButton", inValue );
		}
		
		public function set cancelButton( inValue : Boolean ) : void
		{
			setImplementationProperty( "cancelButton", inValue );
		}
		
		public function set title( inValue : String ) : void
		{
			setImplementationProperty( "title", inValue );
		}
		
		public function set text( inValue : String ) : void
		{
			setImplementationProperty( "text", inValue );
		}
		
		public function set skinClass( inValue : IFactory ) : void
		{
			setImplementationProperty( "skinClass", inValue );
		}
		
		public function set styleName( inValue : String ) : void
		{
			setImplementationProperty( "styleName", inValue );
		}
		
		
	}
}