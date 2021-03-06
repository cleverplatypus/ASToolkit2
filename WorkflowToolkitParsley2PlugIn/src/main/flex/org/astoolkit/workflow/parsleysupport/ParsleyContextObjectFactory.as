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
package org.astoolkit.workflow.parsleysupport
{

	import org.astoolkit.commons.factory.api.IExtendedFactory;
	import org.spicefactory.parsley.core.context.Context;
	import org.spicefactory.parsley.core.registry.DynamicObjectDefinition;
	import org.spicefactory.parsley.core.registry.ObjectDefinition;

	//TODO: Finish implementation
	public class ParsleyContextObjectFactory implements IExtendedFactory
	{
		private var _pid : String;

		public function get pid():String
		{
			return _pid;
		}

		public function set pid(value:String):void
		{
			_pid = value;
		}

		
		private var _context : Context;

		private var _singletonInstance : Boolean;

		private var _type : Class;

		[Inject]
		public function set context( inContext : Context ) : void
		{
			_context = inContext;
		}

		public function set factoryMethod(inValue:String) : void
		{
			// TODO Auto Generated method stub

		}

		public function set factoryMethodArguments(inValue:Array) : void
		{
			// TODO Auto Generated method stub

		}

		public function set properties(inValue:Object) : void
		{
			// TODO Auto Generated method stub

		}

		public function set singletonInstance( inValue : Boolean ) : void
		{
			_singletonInstance = inValue;
		}

		public function set type( inValue : Class ) : void
		{
			_type = inValue;
		}

		public function getInstance(inType:Class, inProperties:Object=null, inFactoryMethodArguments:Array=null, inFactoryMethod:String=null) : *
		{
			var ob : ObjectDefinition = _context.findDefinitionByType( inType );
			return ob is DynamicObjectDefinition ? 
				_context.createDynamicObjectByType( inType ).instance :
				_context.getObjectByType( inType );
		}

		public function newInstance() : *
		{
			return getInstance( _type, null, null, null );
		}
	}
}
