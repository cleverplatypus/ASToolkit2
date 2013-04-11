package org.astoolkit.lang.reflection
{

	import org.astoolkit.lang.reflection.api.IArgument;

	public class Method extends AbstractReflection
	{
		protected var _returnType : Type;

		public function get returnType() : Type
		{
			return _returnType;
		}


		protected var _arguments : Vector.<IArgument>;

		public function get arguments() : Vector.<IArgument>
		{
			return _arguments;
		}


		internal static function create(
			inName : String,
			inScope : String,
			inReturnType : Type,
			inArguments : Vector.<IArgument>,
			inIsStatic : Boolean,
			inOwner : Type
			) : Method
		{
			var out : Method = new Method();
			out._name = inName;
			out._isStatic = inIsStatic;
			out._arguments = inArguments;
			out._scope = inScope;
			out._returnType = inReturnType;
			out._owner = inOwner;
			return out;
		}
	}
}
