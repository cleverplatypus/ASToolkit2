package org.astoolkit.workflow.task.mapping
{
	
	import mx.core.IFactory;
	import avmplus.getQualifiedClassName;
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.internals.GroupUtil;
	
	public class SetTarget extends BaseTask
	{
		public var target : IFactory;
		
		override public function begin() : void
		{
			super.begin();
			
			if(target)
			{
				var mapObject : MapObject = GroupUtil.getParentWorkflow( this ) as MapObject;
				
				if(mapObject)
					mapObject.targetClass = target;
				else
					$[getQualifiedClassName( MapObject )] = target;
			}
		}
	}
}
