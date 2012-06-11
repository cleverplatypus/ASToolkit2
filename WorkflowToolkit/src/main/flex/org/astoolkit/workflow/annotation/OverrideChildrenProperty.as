package org.astoolkit.workflow.annotation
{

	import org.astoolkit.commons.reflection.Metadata;

	[Metadata( name="OverrideChildrenProperty", target="field" )]
	public class OverrideChildrenProperty extends Metadata
	{
		public function get levels() : Number
		{
			return getNumber( "levels" );
		}
	}
}
