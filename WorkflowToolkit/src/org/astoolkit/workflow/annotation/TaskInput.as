package org.astoolkit.workflow.annotation
{
	import org.astoolkit.commons.reflection.Metadata;
	
	import flash.utils.getDefinitionByName;
	
	[Metadata(name="TaskInput", target="field")]
	public class TaskInput extends Metadata
	{
		public function get types() : Vector.<Class>
		{
			return Vector.<Class>( getArray( "types" ).map(
				function( inClassName : String, inIndex : int, inArray : Array ) : Class
				{
					return getDefinitionByName( inClassName ) as Class;
				} ) );
		}
	}
}