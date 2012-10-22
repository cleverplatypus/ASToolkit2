package org.astoolkit.workflow.map
{

	import org.astoolkit.commons.ns.astoolkit_private;

	public final class NextTask extends AbstractMappingProvider
	{
		override public function getTarget() : *
		{
			if( _context )
			{
				return _context.variables.astoolkit_private::nextTaskProperties;
			}
		}
	}
}
