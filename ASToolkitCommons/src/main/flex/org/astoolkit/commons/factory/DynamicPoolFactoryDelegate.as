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
	
	public class DynamicPoolFactoryDelegate implements IPooledFactoryDelegate
	{
		private var _newInstanceHandler : Function;
		private var _destroyHandler : Function;
		private var _releaseHandler : Function;
		private var _postCreateHandler : Function;
		
		public function DynamicPoolFactoryDelegate( 
			inNewInstanceHandler : Function = null,
			inPostCreateHandler : Function = null,
			inDestryoHandler : Function = null,
			inReleaseHandler : Function = null
			)
		{
			_newInstanceHandler = inNewInstanceHandler;
			_postCreateHandler = inPostCreateHandler;
			_releaseHandler = inReleaseHandler;
			_destroyHandler = inDestryoHandler;
		}
		
		public function get delegateInstantiation() : Boolean
		{
			return _newInstanceHandler != null;
		}
		
		public function newInstance(inClass:Class, inProperties:Object) : Object
		{
			return _newInstanceHandler( inClass, inProperties );
		}
		
		public function onDestroy(inTask:Object) : void
		{
		}
		
		public function onRelease(inTask:Object) : void
		{
		}
		
		public function onPostCreate(inInstance:Object) : void
		{
			if ( _postCreateHandler != null )
				_postCreateHandler( inInstance );
		}
	}
}
