package org.astoolkit.lang.util
{

	public class Tuple
	{
		private var _value : Object;

		private var _name : String;

		public function get value() : Object
		{
			return _value;
		}

		public function get name() : String
		{
			return _name;
		}

		public function Tuple( inName : String, inValue : Object )
		{
			_name = inName;
			_value = inValue;
		}


	}
}
