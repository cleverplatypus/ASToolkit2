package org.astoolkit.workflow.conditional
{

	import org.astoolkit.commons.conditional.BaseConditionalExpression;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.workflow.api.IWorkflowContext;
	import org.astoolkit.workflow.core.Workflow;

	public class BaseConditionalWorkflowExpression extends BaseConditionalExpression implements IContextAwareElement
	{

		public function BaseConditionalWorkflowExpression()
		{
			super();
		}

		protected var _context : IWorkflowContext;

		public function set context( inValue : IWorkflowContext ) : void
		{
			_context = inValue;
		}

		override public function initialized( inDocument : Object, inId : String ) : void
		{
			super.initialized( inDocument, inId );

			if( inDocument is Workflow )
			{
				( inDocument as Workflow ).astoolkit_private::registerContextAwareElement( this );
			}
		}
	}
}
