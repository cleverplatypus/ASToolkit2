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

	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.logging.ILogger;
	import mx.logging.Log;

	import org.astoolkit.commons.factory.api.IFactoryResolver;
	import org.astoolkit.commons.factory.api.IFactoryResolverClient;
	import org.astoolkit.commons.factory.api.IPooledFactory;
	import org.astoolkit.commons.utils.getLogger;

	public class FactoryTransformer extends BaseDataTransformer implements IFactoryResolverClient
	{
		private static const LOGGER : ILogger = getLogger( FactoryTransformer );

		private var _factoryDelegate : IFactoryResolver;

		public var factory : IFactory;

		public var factoryMethod : String;

		public var factoryMethodArguments : Array;

		public function set factoryResolver( inValue : IFactoryResolver ) : void
		{
			_factoryDelegate = inValue
		}

		public var properties : Object;

		/**
		 * @private
		 */
		override public function get supportedDataTypes() : Vector.<Class>
		{
			return Vector.<Class>( [ Object ] );
		}

		public var type : Class;

		override public function transform( inData : Object, inExpression : Object, inTarget : Object = null ) : Object
		{
			var usedFactory : IFactory = factory ? factory : null;

			if( !usedFactory && _factoryDelegate )
			{
				usedFactory = _factoryDelegate.getFactoryForType( type );
			}

			if( !usedFactory )
				usedFactory = new ClassFactory();

			if( usedFactory is IPooledFactory )
			{
				return IPooledFactory( usedFactory ).getInstance( type, properties );
			}
			else if( usedFactory is ClassFactory )
			{
				ClassFactory( usedFactory ).properties = properties;
				ClassFactory( usedFactory ).generator = type;
				return usedFactory.newInstance();
			}
			else
			{
				if( properties )
					LOGGER.warn(
						"Ignore factory properties. \n" +
						"Unknown properties set method for factory class: {0}",
						getQualifiedClassName( usedFactory ) );
				return usedFactory.newInstance();
			}
			return null;
		}
	}
}
