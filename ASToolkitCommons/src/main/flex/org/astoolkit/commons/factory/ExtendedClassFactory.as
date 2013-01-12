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

	import flash.utils.getQualifiedClassName;
	import org.astoolkit.commons.factory.api.IExtendedFactory;
	import org.astoolkit.commons.reflection.AutoConfigUtil;
	import org.astoolkit.commons.wfml.IAutoConfigContainerObject;

	[DefaultProperty("autoConfigChildren")]
	public class ExtendedClassFactory implements IExtendedFactory, IAutoConfigContainerObject
	{

		public static function create( 
			inType : Class, 
			inProperties : Object = null, 
			inFactoryMethodArguments:Array=null, 
			inFactoryMethod:String=null ) : ExtendedClassFactory
		{
			var out : ExtendedClassFactory = new ExtendedClassFactory();
			out._type = inType;
			out._defaultProperties = inProperties;
			out._factoryMethodArguments = inFactoryMethodArguments;
			out._factoryMethod = inFactoryMethod;
			return out;
		}

		private var _autoConfigChildren : Array;

		private var _document : Object;

		private var _id : String;

		protected var _defaultProperties : Object;

		protected var _factoryMethod : String;

		protected var _factoryMethodArguments : Array;

		protected var _pid : String;

		protected var _type : Class;

		public function set autoConfigChildren( inValue : Array ) : void
		{
			_autoConfigChildren  = inValue;
		}

		public function set factoryMethod(inValue:String) : void
		{
			_factoryMethod = inValue;
		}

		[AutoConfig]
		public function set factoryMethodArguments(inValue:Array) : void
		{
			_factoryMethodArguments = inValue;
		}

		public function get pid() : String
		{
			return _pid;
		}

		public function set pid(value:String) : void
		{
			_pid = value;
		}

		public function set properties(inValue:Object) : void
		{
			_defaultProperties = inValue;
		}

		public function set type(inValue:Class) : void
		{
			_type = inValue;
		}

		public function getInstance( 
			inType : Class, 
			inProperties : Object = null, 
			inFactoryMethodArguments:Array=null, 
			inFactoryMethod:String=null ) : *
		{
			var out : Object;

			if( !inType )
				throw new Error( "Factory type is not defined" );

			if( inFactoryMethod )
			{
				if( inType.hasOwnProperty( inFactoryMethod ) &&
					inType[ inFactoryMethod ] is Function )
				{
					out = ( inType[ inFactoryMethod ] as Function ).apply( inType, inFactoryMethodArguments );
				}
				else
					throw new Error( "Factory method '" + inFactoryMethod + "' not defined for type " +
						getQualifiedClassName( inType ) );
			}

			if( out && inProperties )
			{
				for( var k : String in inProperties )
				{
					out[ k ] = inProperties[ k ];
				}
			}
			return out;
		}

		public function initialized( inDocument : Object, inId : String ) : void
		{
			_document = inDocument;
			_id = inId;
			AutoConfigUtil.autoConfig( this, _autoConfigChildren );
		}

		public function newInstance() : *
		{
			return getInstance( _type, _defaultProperties, _factoryMethodArguments, _factoryMethod );
		}
	}
}
