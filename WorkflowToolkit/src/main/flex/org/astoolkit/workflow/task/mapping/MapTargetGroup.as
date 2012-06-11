package org.astoolkit.workflow.task.mapping
{

	import mx.core.IFactory;
	import org.astoolkit.workflow.core.Group;

	public class MapTargetGroup extends Group
	{

		[OverrideChildrenProperty]
		public var target : IFactory;
	}
}
