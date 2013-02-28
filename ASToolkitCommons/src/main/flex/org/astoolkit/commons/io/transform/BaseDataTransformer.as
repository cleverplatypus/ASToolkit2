/*

Copyright 2009 Nicola Dal Pont

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Version 2.x

*/
package org.astoolkit.commons.io.transform
{

	import flash.utils.getQualifiedClassName;
	import org.astoolkit.commons.io.transform.api.IIODataTransformer;

	public class BaseDataTransformer implements IIODataTransformer
	{

		protected var _next : IIODataTransformer;

		protected var _parent : IIODataTransformer;

		protected var _pid : String;

		public function get next() : IIODataTransformer
		{
			return _next;
		}

		public function set next( inValue : IIODataTransformer ) : void
		{
			_next = inValue;
		}

		public function get parent() : IIODataTransformer
		{
			return _parent;
		}

		public function set parent( inValue : IIODataTransformer ) : void
		{
			_parent = inValue;
		}

		public function get pid() : String
		{
			return _pid;
		}

		public function set pid( value : String ) : void
		{
			_pid = value;
		}

		public function get priority() : int
		{
			return -1;
		}

		public function get supportedDataTypes() : Vector.<Class>
		{
			return null;
		}

		public function get supportedExpressionTypes() : Vector.<Class>
		{
			return null;
		}

		public function BaseDataTransformer()
		{
			if( getQualifiedClassName( this ) == getQualifiedClassName( BaseDataTransformer ) )
				throw new Error( "BaseDataTransformer is abstract" );
		}

		public function chain( inNext : IIODataTransformer ) : IIODataTransformer
		{
			inNext.parent = this;
			return _next = inNext;
		}

		public function isValidExpression( inExpression : Object ) : Boolean
		{
			return false;
		}

		public function root() : IIODataTransformer
		{
			var trans : IIODataTransformer = this;

			while( trans.parent )
				trans = trans.parent
			return parent;
		}

		public function transform( inData : Object, inExpression : Object, inTarget : Object = null ) : Object
		{
			throw new Error( "BaseDataTransformer is abstract" );
			return null;
		}
	}
}
