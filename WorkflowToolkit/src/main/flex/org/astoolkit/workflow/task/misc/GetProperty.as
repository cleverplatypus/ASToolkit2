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
package org.astoolkit.workflow.task.misc
{

	import flash.utils.getQualifiedClassName;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.utils.StringUtil;
	import org.astoolkit.commons.factory.api.IFactoryResolver;
	import org.astoolkit.workflow.api.IFactoryResolverClientTask;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Gets a target object's property value and outputs the latter into the pipeline.
	 * This task is an <code>IFactoryResolverClient</code>, therefore it will try to
	 * instanciate targetClass using a resolved factory first.
	 */
	public class GetProperty extends BaseTask implements IFactoryResolverClientTask
	{
		private var _allowDefaultFactory:Boolean;

		private var _factoryResolver : IFactoryResolver;

		private var _path : String;

		private var _target : Object;

		private var _targetClass : Class;

		private var _targetFactory : IFactory;

		public function set allowDefaultFactory( inValue : Boolean ) : void
		{
			_allowDefaultFactory = inValue;
		}

		public function set factoryResolver( inValue : IFactoryResolver ) : void
		{
			_factoryResolver = inValue;
		}

		public function set path( inValue : String ) : void
		{
			inValue = inValue ? StringUtil.trim( inValue ) : "";

			if( inValue != "" && inValue != "." && !inValue.match( /^\w+(\.\w+)?$/ ) )
				throw new Error( "Invalid property path format" );
			_path = inValue;
		}

		public function set target( inValue : Object ) : void
		{
			_target = inValue;
		}

		public function set targetClass( inValue : Class ) : void
		{
			_targetClass = inValue;
		}

		[AutoAssign]
		public function set targetFactory( inValue : IFactory ) : void
		{
			_targetFactory = inValue;
		}

		override public function begin() : void
		{
			super.begin();
			var aTarget : Object;

			if( _target )
				aTarget = _target;
			else if( _targetFactory )
				aTarget = _targetFactory.newInstance();
			else if( _targetClass )
			{
				var factory : IFactory = _factoryResolver.getFactoryForType( _targetClass );

				if( !factory )
				{
					if( _allowDefaultFactory )
						factory = new ClassFactory( _targetClass );
					else
					{
						fail( "No factories found for '{0}'", 
							getQualifiedClassName( _targetClass ) );
						return;
					}
				}
				aTarget = factory.newInstance();
			}
			else
				aTarget = _document;

			if( _path == "." || _path == "" )
			{
				complete( aTarget );
				return;
			}
			var obj : Object = aTarget;

			for each( var seg : String in _path.split( "." ) )
			{
				if( !obj.hasOwnProperty( seg ) )
				{
					fail( "Cannot resolve path '{0}' in object {1}",
						_path,
						getQualifiedClassName( aTarget ) );
					return
				}
				obj = obj[ seg ];
			}
			complete( obj );
		}
	}
}
