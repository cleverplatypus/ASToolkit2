package org.astoolkit.workflow.task.mapping
{
	
	import mx.core.IFactory;
	import org.astoolkit.commons.factory.MonoInstanceFactory;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.workflow.api.IMapTask;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.core.BaseElement;
	import org.astoolkit.workflow.core.Workflow;
	use namespace astoolkit_private;
	
	[Bindable]
	public class MapObject extends Workflow implements IMapTask
	{
		private var _target : IFactory;
		
		private var _source : Object;
		
		public var property : String;
		
		public var value : Object;
		
		private var _targetObject : Object;
		
		public var map : Object;
		
		public var target : Object;
		
		public var fun : Function;
		
		override public function initialize() : void
		{
			super.initialize();
		}
		
		override public function prepare() : void
		{
			super.prepare();
			_targetObject = null;
		}
		
		override public function begin() : void
		{
			super.begin();
		}
		
		override protected function setSubtaskPipelineData( inTask : IWorkflowTask ) : void
		{
			super.setSubtaskPipelineData( inTask );
			
			if ( inTask is IMapTask && inTask is BaseElement )
			{
				if ( !BaseElement( inTask ).astoolkit_private::propertyIsUserDefined( "source" ) )
				{
					IMapTask( inTask ).source = getSource();
				}
				
				if ( !BaseElement( inTask ).astoolkit_private::propertyIsUserDefined( "target" ) )
				{
					IMapTask( inTask ).targetClass = MonoInstanceFactory.of( getTarget() );
				}
			}
		}
		
		private function getTarget() : Object
		{
			if ( !_targetObject )
			{
				if ( _target )
					_targetObject = _target.newInstance();
				else
					_targetObject = {};
			}
			return _targetObject;
		}
		
		private function getSource() : Object
		{
			if ( map && source && context )
			{
				context.config.inputFilterRegistry.getTransformer( source, map ).transform( source, map );
			}
			return source;
		}
		
		public function get source() : Object
		{
			return _source;
		}
		
		[InjectPipeline]
		public function set source( inValue : Object ) : void
		{
			_source = inValue;
		}
		
		public function get targetClass() : IFactory
		{
			return _target;
		}
		
		public function set targetClass( inValue : IFactory ) : void
		{
			_target = inValue;
		}
		
		override public function get output() : *
		{
			return _targetObject;
		}
	}
}