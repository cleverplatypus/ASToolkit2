package org.astoolkit.commons.reflection
{

	public class Method extends AbstractReflection
	{
		static function create(
			inName : String ) : Method
		{
			var out : Method = new Method();
			out._name = inName;
			return out;
		}
	}
}
