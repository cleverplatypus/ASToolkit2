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
package org.astoolkit.commons.mapping
{

	import org.astoolkit.commons.factory.DynamicPoolFactoryDelegate;
	import org.astoolkit.commons.factory.api.IPooledFactory;
	import org.astoolkit.commons.factory.PooledFactory;
	import org.astoolkit.commons.io.transform.DefaultDataTransformRegistry;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	import org.astoolkit.commons.mapping.api.IPropertiesMapper;

	public class DataMap
	{
		private static var _factory : PooledFactory;

		private static var _staticInstance : DataMap;

		private static var _transformerRegistry : IIODataTransformerRegistry;

		public static function clearSingleton() : void
		{
			_staticInstance = null;
		}

		public static function get to() : DataMap
		{
			if( !_staticInstance )
				_staticInstance = new DataMap();
			return _staticInstance;
		}

		public function object( inTarget : Object, inMapping : Object, inStrict : Boolean = true ) : IPropertiesMapper
		{
			return new MapperWrapper( factory, inMapping, inTarget, inStrict );
		}

		public function newObject( inTargetClass : Class, inMapping : Object, inStrict : Boolean = true ) : IPropertiesMapper
		{
			return new MapperWrapper( factory, inMapping, inTargetClass, inStrict );
		}

		public function property( inTarget : Object, inPropertyName : String ) : IPropertiesMapper
		{
			var map : Object = {};
			map[ inPropertyName ] = ".";
			return object( inTarget, map, true );
		}

		public function set transformerRegistry( inValue : IIODataTransformerRegistry ) : void
		{
			_transformerRegistry = inValue;
		}

		private function get factory() : IPooledFactory
		{
			if( !_factory )
			{
				_factory = new PooledFactory();
				_factory.type = SimplePropertiesMapper;
				_factory.delegate = new DynamicPoolFactoryDelegate(
					null, postCreateFactoryHandler, null, null );
			}
			return _factory;
		}

		private function postCreateFactoryHandler( inInstance : SimplePropertiesMapper ) : void
		{
			if( !_transformerRegistry )
				_transformerRegistry = new DefaultDataTransformRegistry();
			inInstance.transformerRegistry = _transformerRegistry;
			inInstance.targetClass = null;
			inInstance.target = null;
			inInstance.mapping = null;
		}
	}
}

import mx.core.ClassFactory;
import mx.core.IFactory;

import org.astoolkit.commons.factory.api.IPooledFactory;
import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
import org.astoolkit.commons.mapping.SimplePropertiesMapper;
import org.astoolkit.commons.mapping.api.IPropertiesMapper;

class MapperWrapper implements IPropertiesMapper
{
	public function MapperWrapper(
		inFactory : IPooledFactory,
		inMapping : Object,
		inTarget : Object,
		inStrict : Boolean
		)
	{
		_strict = inStrict;
		_target = inTarget is Class ? null : inTarget;
		_targetClass = inTarget is Class ? inTarget as Class : null;
		_mapping = inMapping;
		_factory = inFactory;
	}

	private var _factory : IPooledFactory;

	private var _mapping : Object;

	private var _strict : Boolean;

	private var _target : Object;

	private var _targetClass : Class;

	private var _transformerRegistry : IIODataTransformerRegistry;

	public function hasTarget() : Boolean
	{
		return true;
	}

	public function map( inSource : Object, inTarget : Object = null ) : *
	{
		var mapper : IPropertiesMapper = create();
		var out : *;

		if( _targetClass )
		{
			mapper.targetClass = new ClassFactory( _targetClass );
			out = mapper.map( inSource );
		}
		else
			out = mapper.map( inSource, _target );
		_factory.release( mapper );
		return out;
	}

	public function set mapFailDelegate( inFunction : Function ) : void
	{
	}

	public function mapWith( inSource : Object, inMapping : Object, inTarget : Object = null ) : *
	{
		var mapper : IPropertiesMapper = create();
		var out : * = mapper.mapWith(
			inSource,
			inMapping,
			inTarget != null ? inTarget : _target
			);
		_factory.release( mapper );
		return out;
	}

	public function set strict( inValue : Boolean ) : void
	{
	}

	public function set target( inValue : Object ) : void
	{
		_target = inValue;
	}

	public function set targetClass( inClass : IFactory ) : void
	{
	}

	public function set transformerRegistry( inValue : IIODataTransformerRegistry ) : void
	{
		_transformerRegistry = inValue;
	}

	private function create() : IPropertiesMapper
	{
		var mapper : SimplePropertiesMapper = _factory.newInstance();
		mapper.mapping = _mapping;
		mapper.strict = _strict;
		return mapper;
	}
}
