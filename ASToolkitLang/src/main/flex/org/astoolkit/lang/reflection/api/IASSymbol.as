package org.astoolkit.lang.reflection.api
{

	import org.astoolkit.lang.reflection.Type;

	public interface IASSymbol
	{
		function get name() : String;
		function get annotations() : Vector.<IAnnotation>
		function getAnnotationsOfType( inClass : Class ) : Vector.<IAnnotation>;
		function getAnnotationsWithName( inName : String ) : Vector.<IAnnotation>;
		function get isStatic() : Boolean;
		function get scope() : String;
		function get owner() : Type;
	}
}
