package org.astoolkit.workflow.task.api
{
	import mx.core.IFactory;

	[Bindable][Template]
	public interface ISendMessage
	{
		function set message( inMessage : Object ) : void;
		function set scope( inScope : Object ) : void;
		function set isCommand( inValue : Boolean ) : void;
		function set messageFactory( inValue : IFactory ) : void;
		function set messagePropertiesMapping( inValue : Object ) : void;
		function set messageMappingFailurePolicy( inValue : String ) : void;
	}
}