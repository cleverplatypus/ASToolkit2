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
package org.astoolkit.commons.factory
{

	import mx.core.IMXMLObject;

	import org.astoolkit.commons.factory.api.IExtendedFactory;

	public class ClassFactoryFacade implements IExtendedFactory, IMXMLObject
	{
		private static const POOLED_TRUE : String = "true";

		private static const POOLED_FALSE : String = "false";

		private static const POOLED_ANNOTATION_DRIVEN : String = "annotationDriven";

		private var _pid : String;

		public function get pid() : String
		{
			return _pid;
		}

		public function set pid( value : String ) : void
		{
			_pid = value;
		}


		private var _factory : IExtendedFactory;

		private var _pooled : String;

		public function set factoryMethod( inValue : String ) : void
		{

		}

		public function set factoryMethodArguments( inValue : Array ) : void
		{
		}

		[Inspectable( enumeration="annotationDriven,true,false", defaultValue="annotationDriven" )]
		public function set pooled( inValue : String ) : void
		{
			_pooled = inValue;
		}

		public function set properties( inValue : Object ) : void
		{

		}

		public function set type( inValue : Class ) : void
		{
		}

		public function getFactory() : IExtendedFactory
		{
			if( !_factory )
			{
				if( _pooled == POOLED_TRUE )
				{
					_factory = new PooledFactory();
				}
				else if( _pooled == POOLED_FALSE )
				{

				}

			}
			return _factory;
		}

		public function getInstance( inType : Class, inProperties : Object = null, inFactoryMethodArguments : Array = null, inFactoryMethod : String = null ) : *
		{
			return null;
		}

		public function initialized( document : Object, id : String ) : void
		{
		}

		public function newInstance() : *
		{
			return null;
		}
	}
}
