package org.astoolkit.workflow.api
{
	public interface IMapTask extends IWorkflowTask
	{
		function set source( inValue : Object ) : void;
		function get source() : Object;
		function set target( inValue : Object ) : void;
		function get target() : Object;
	}
}