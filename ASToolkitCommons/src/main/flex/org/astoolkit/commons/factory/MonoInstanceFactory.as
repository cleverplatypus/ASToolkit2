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
	
	import mx.core.IFactory;
	
	/**
	 * Utility <code>IFactory</code> implementation
	 * that returns the same instance every time
	 * <code>newInstance()</code> is called
	 */
	public class MonoInstanceFactory implements IFactory
	{
		public static function of( inInstance : Object ) : MonoInstanceFactory
		{
			return new MonoInstanceFactory( inInstance, new SingletonEnforcer());
		}
		
		public function MonoInstanceFactory( inInstance : Object, inEnforcer : SingletonEnforcer )
		{
			if(inEnforcer == null)
				throw new Error( "MonoInstanceFactory cannot be instanciated " +
					"directly. Use MonoInstanceFactory.of( inObject ) instead." );
			_instance = inInstance;
		}
		
		private var _instance : Object;
		
		public function newInstance() : *
		{
			return _instance;
		}
	}
}

class SingletonEnforcer
{
}
