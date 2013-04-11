package org.astoolkit.lang.reflection.api
{

	import org.astoolkit.lang.reflection.Type;

	public interface IArgument
	{
		function get name() : String;
		function get type() : Type;
		function get defaultValue() : *;
	}
}
