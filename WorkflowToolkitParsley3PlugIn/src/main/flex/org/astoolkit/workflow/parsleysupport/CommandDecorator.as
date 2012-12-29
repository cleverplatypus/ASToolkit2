package org.astoolkit.workflow.parsleysupport
{
	import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
	import org.spicefactory.parsley.core.builder.ObjectDefinitionDecorator;
	
	[Metadata(name="Command", types="method")]
	public class CommandDecorator extends Object implements ObjectDefinitionDecorator
	{
		[Attribute]
		public var selector:*;
		
		[Attribute]
		public var order:int = 0;
		
		[Target]
		public var method:String;
		
		public function decorate( inBuilder:ObjectDefinitionBuilder):void
		{
			inBuilder
				.method( method )
				.process( new CommandProcessor() )
				.minParams(1);
		}
	}
}