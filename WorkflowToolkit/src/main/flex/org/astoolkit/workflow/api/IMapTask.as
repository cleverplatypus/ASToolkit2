package org.astoolkit.workflow.api
{
	
	import mx.core.IFactory;
	
	public interface IMapTask extends IWorkflowTask
	{
		function set source( inValue : Object ) : void;
		function get source() : Object;
		function set targetClass( inValue : IFactory ) : void;
		function get targetClass() : IFactory;
		function get target() : Object;
		function set target( inValue : Object ) : void;
		function set property( inValue : String ) : void;
		function get property() : String;
	}
}
