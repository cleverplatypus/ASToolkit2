package org.astoolkit.workflow.api
{
	
	import mx.core.IFactory;
	
	public interface IMapTask extends IWorkflowTask
	{
		function get property() : String;
		function set property( inValue : String ) : void;
		function get source() : Object;
		function set source( inValue : Object ) : void;
		function get target() : Object;
		function set target( inValue : Object ) : void;
		function get targetClass() : IFactory;
		function set targetClass( inValue : IFactory ) : void;
	}
}
