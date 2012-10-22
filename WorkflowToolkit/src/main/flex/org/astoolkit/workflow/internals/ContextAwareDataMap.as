package org.astoolkit.workflow.internals
{

	import org.astoolkit.commons.mapping.DataMap;
	import org.astoolkit.commons.mapping.api.IPropertiesMapper;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.workflow.api.IWorkflowContext;

	internal final class ContextAwareDataMap extends DataMap
	{

		public function ContextAwareDataMap( inContext : IWorkflowContext )
		{
			super();
			_context = inContext;
		}

		private var _context : IWorkflowContext;

		public function nextTask( inMapping : Object ) : IPropertiesMapper
		{
			if( inMapping is String )
				return property( _context.variables.astoolkit_private::nextTaskProperties, inMapping as String );
			else
				return object( _context.variables.astoolkit_private::nextTaskProperties, inMapping, true );
		}
	}
}
