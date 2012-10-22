package org.astoolkit.workflow.task.api
{

	[Template]
	public interface IWaitForMessage
	{
		function set messageClass( inValue : Class ) : void;
		function set selector( inValue : Object ) : void;
	}
}
