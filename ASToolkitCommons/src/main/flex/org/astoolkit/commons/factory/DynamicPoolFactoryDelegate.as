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
	import org.astoolkit.commons.factory.api.IPooledFactoryDelegate;

	public class DynamicPoolFactoryDelegate implements IPooledFactoryDelegate
	{
		public function DynamicPoolFactoryDelegate(
			inFactory : IFactory = null,
			inPostCreateHandler : Function = null,
			inDestryoHandler : Function = null,
			inReleaseHandler : Function = null
			)
		{
			_factory = inFactory;
			_postCreateHandler = inPostCreateHandler;
			_releaseHandler = inReleaseHandler;
			_destroyHandler = inDestryoHandler;
		}

		private var _destroyHandler : Function;
		
		private var _factory : IFactory;


		private var _postCreateHandler : Function;

		private var _releaseHandler : Function;
		
		public function get factory() : IFactory
		{
			return _factory;
		}
		
		public function onDestroy( inTask : Object ) : void
		{
		}

		public function onPostCreate( inInstance : Object ) : void
		{
			if( _postCreateHandler != null )
				_postCreateHandler( inInstance );
		}

		public function onRelease( inInstance : Object ) : void
		{
			if( _releaseHandler != null )
				_releaseHandler( inInstance );
		}
	}
}
