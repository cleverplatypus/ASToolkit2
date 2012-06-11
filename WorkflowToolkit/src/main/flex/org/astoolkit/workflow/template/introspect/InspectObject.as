package org.astoolkit.workflow.template.introspect
{

	import org.astoolkit.workflow.core.BaseTaskTemplate;
	import org.astoolkit.workflow.task.api.IInspectObject;

	public dynamic class InspectObject extends BaseTaskTemplate implements IInspectObject
	{
		public function set object( inValue : Object ) : void
		{
			setImplementationProperty( "object", inValue );
		}

		public function set pause( inValue : Boolean ) : void
		{
			setImplementationProperty( "pause", inValue );
		}
	}
}
