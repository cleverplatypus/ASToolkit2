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
	import flash.utils.setTimeout;
	import mx.core.ClassFactory;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ArrayUtil;
	import mx.utils.UIDUtil;

	public class PooledFactory implements IPooledFactory
	{
		private static const LOGGER : ILogger =
			Log.getLogger( getQualifiedClassName( PooledFactory ).replace( /:+/g, "." ) );

		public static function create(
			inDefaultType : Class,
			inDelegate : IPooledFactoryDelegate ) : PooledFactory
		{
			var out : PooledFactory = new PooledFactory();
			out.defaultType = inDefaultType;
			out.delegate = inDelegate;
			return out;
		}

		public var defaultProperties : Object;

		public var minimumStock : int = 1;

		public var poolCleanupDelay : int = 5000;

		private var _backupProperties : Array;

		private var _busyObjects : Array = [];

		private var _defaultType : Class;

		private var _delegate : IPooledFactoryDelegate;

		private var _genericFactory : ClassFactory = new ClassFactory();

		private var _pool : Array = [];

		private var _propertiesBackup : Object = {};

		public function set backupProperties( inProperties : Array ) : void
		{
			_backupProperties = inProperties;
		}

		public function cleanup() : void
		{
			if( _busyObjects.length > 0 )
				throw new Error(
					"Error cleaning up the pool. Some objects are still in use" );

			if( _delegate )
			{
				for each( var object : Object in _pool )
				{
					_delegate.onDestroy( object );
				}
			}
			_pool = [];
		}

		public function get defaultType() : Class
		{
			return _defaultType;
		}

		public function set defaultType( inValue : Class ) : void
		{
			_defaultType = inValue;
		}

		public function set delegate( inDelegate : IPooledFactoryDelegate ) : void
		{
			_delegate = inDelegate;
		}

		/**
		 * creates a new instance of the give type or of <code>defaultType</code> class
		 * or returns a pooled instance
		 */
		public function getInstance( inType : Class = null, inProperties : Object = null ) : *
		{
			if( !inType )
				inType = defaultType;

			if( !inProperties )
				inProperties = defaultProperties;
			var out : Object;

			if( _delegate && _delegate.delegateInstantiation )
				out = _delegate.newInstance( inType, inProperties );
			else
			{
				_genericFactory.properties = inProperties;
				_genericFactory.generator = inType;
				out = _genericFactory.newInstance();
			}

			if( _delegate )
				_delegate.onPostCreate( out );
			_pool.push( out );

			if( _backupProperties && _backupProperties.length > 0 )
			{
				var backup : Object =
					_propertiesBackup.hasOwnProperty( UIDUtil.getUID( out ) );

				if( !backup )
				{
					backup = {};
					_propertiesBackup[ UIDUtil.getUID( out ) ] = backup;
				}

				for each( var p : String in _backupProperties )
				{
					if( out.hasOwnProperty( p ) )
						backup[ p ] = out[ p ];
					else
						LOGGER.warn( "{0} doesn't have a '{1}' property", getQualifiedClassName( out ), p );
				}
			}
			return out;
		}

		public function hasPooledInstance( inType : Object ) : Boolean
		{
			return false;
		}

		public function newInstance() : *
		{
			if( defaultType )
				return getInstance( defaultType, defaultProperties );
			LOGGER.warn( "PooledFactory newInstance() is returning an instance of Object " +
				"because defaultType wasn't set" );
			return {};
		}

		/**
		 * returns an object to the pool
		 */
		public function release( inObject : Object ) : void
		{
			_busyObjects.splice( ArrayUtil.getItemIndex( inObject, _busyObjects ), 1 );
			_pool.push( inObject );

			if( _backupProperties && _backupProperties.length > 0 )
			{
				var backup : Object =
					_propertiesBackup[ UIDUtil.getUID( inObject ) ];

				for each( var p : String in _backupProperties )
				{
					if( inObject.hasOwnProperty( p ) )
						inObject[ p ] = backup[ p ];
				}
			}

			if( _delegate )
				_delegate.onRelease( inObject );

			if( _busyObjects.length == 0 )
				setTimeout( vacuum, poolCleanupDelay );
		}

		/**
		 * cleans up the pool retaining only <code>minimumStock</code> instances
		 */
		public function vacuum( inType : Object = null ) : void
		{
			if( _busyObjects.length == 0 )
			{
				while( _pool.length > minimumStock )
				{
					var object : Object = _pool.pop();

					if( _propertiesBackup.hasOwnProperty( UIDUtil.getUID( object ) ) )
						delete _propertiesBackup[ UIDUtil.getUID( object ) ];

					if( _delegate )
						_delegate.onDestroy( object );
				}
			}
		}
	}
}
