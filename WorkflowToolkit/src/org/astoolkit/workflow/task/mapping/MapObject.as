package org.astoolkit.workflow.task.mapping
{
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.workflow.api.IMapTask;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.core.BaseElement;
	import org.astoolkit.workflow.core.Workflow;

	use namespace astoolkit_private;
	
	[Bindable]
	public class MapObject extends Workflow implements IMapTask
	{
		private var _target : Object;
		private var _source : Object;
		public var propertyName : String;
		public var value : Object;
		private var _targetObject : Object;
		public var map : Object;
		
		
		override public function initialize() : void
		{
			super.initialize();
		}
		
		override public function prepare() : void
		{
			super.prepare();
		}

		override protected function setSubtaskPipelineData( inTask : IWorkflowTask ) : void
		{
			super.setSubtaskPipelineData( inTask );
			if( inTask is IMapTask && inTask is BaseElement )
			{
				if( !BaseElement( inTask ).astoolkit_private::propertyIsUserDefined( "source" ) )
				{
					IMapTask( inTask ).source = getSource();
				}
				if( !BaseElement( inTask ).astoolkit_private::propertyIsUserDefined( "target" ) )
				{
					IMapTask( inTask ).target = getTarget();
				}
			}
		}
		
		
		private function getTarget() : Object
		{
			return null;
		}
		
		private function getSource() : Object
		{
			if( map && source && context )
			{
				context.config.inputFilterRegistry.getFilter( source, map ).filter( source, map );
			}
			return source;
		}

		public function get source() : Object
		{
			return _source;
		}

		public function set source( inValue : Object ) : void
		{
			_source = inValue;
		}

		public function get target():Object
		{
			return _target;
		}

		public function set target( inValue : Object ) : void
		{
			_target = inValue;
		}

		override public function get output() : *
		{
			return _targetObject;
		}
	}
}