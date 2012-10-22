package org.astoolkit.workflow.map
{

	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.IMXMLObject;
	
	import org.astoolkit.commons.mapping.api.IPropertyMappingDescriptor;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.workflow.api.IWorkflow;
	import org.astoolkit.workflow.api.IWorkflowContext;
	import org.astoolkit.workflow.api.IWorkflowTask;

	[DefaultProperty( "mappings" )]
	internal class AbstractMappingProvider implements IPropertyMappingDescriptor, IMXMLObject
	{


		public function AbstractMappingProvider()
		{
			if( getQualifiedClassName( this ) == getQualifiedClassName( AbstractMappingProvider ) )
			{
				throw new Error( getQualifiedClassName( this ) + " is abstract" );
			}
		}

		public var mappings : Vector.<Mapping>;

		protected var _context : IWorkflowContext;

		private var _strict : Boolean;

		public function getMapping() : Object
		{
			var out : Object = {};

			for each( var entry : Mapping in mappings )
			{
				out[ entry.target ] = entry.source;
			}
			return out;
		}

		public function getTarget() : *
		{
			return undefined;
		}

		public function initialized( inDocument : Object, inId : String ) : void
		{
			if( !inDocument is IWorkflow )
				throw new Error( getQualifiedClassName( this ) +
					" can only be used in a Workflow" );
			BindingUtils.bindSetter( onContextChange, inDocument, "context" );
		}

		public function set strict( inValue : Boolean ) : void
		{
			_strict = inValue;
		}
		
		public function get strict():Boolean
		{
			return _strict;
		}
		
		
		private function onContextChange( inValue : IWorkflowContext ) : void
		{
			_context = inValue;
		}
	}
}
