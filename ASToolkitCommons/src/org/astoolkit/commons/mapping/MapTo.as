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

*/package org.astoolkit.commons.mapping
{
	import org.astoolkit.commons.factory.IPooledFactory;
	import org.astoolkit.commons.factory.PooledFactory;

	public final class MapTo
	{
		private static var _factory : PooledFactory;
				
		public function MapTo()
		{
			throw Error( "Static class. You cannot instanciate it");
		}
		
		private static function get factory() : IPooledFactory
		{
			if( !_factory )
			{
				_factory = new PooledFactory();
				_factory.defaultType = SimplePropertiesMapper;
			}
			return _factory;
		}
		
		public static function object( 
			inTarget : Object, 
			inMapping : Object, 
			inStrict : Boolean = true ) : IPropertiesMapper
		{
			return new MapperWrapper( factory, inMapping, inTarget, inStrict );
		}
		
		public static function property(
			inTarget : Object,
			inPropertyName : String ) : IPropertiesMapper
		{
			var map : Object = {};
			map[ inPropertyName ] = ".";
			return object( inTarget, map, true );
		}
	}
}
import org.astoolkit.commons.factory.IPooledFactory;
import org.astoolkit.commons.mapping.IPropertiesMapper;
import org.astoolkit.commons.mapping.SimplePropertiesMapper;

import mx.core.IFactory;

class MapperWrapper implements IPropertiesMapper
{
	private var _mapping : Object;
	private var _target : Object;
	private var _factory : IPooledFactory;
	private var _strict : Boolean;
	
	public function hasTarget():Boolean
	{
		return true;
	}
	
	public function set target(inValue:Object):void
	{
		_target = inValue;
	}
	
	
	public function MapperWrapper( 
		inFactory : IPooledFactory,
		inMapping : Object,
		inTarget : Object,
		inStrict : Boolean )
	{
		_strict = inStrict;
		_target = inTarget;
		_mapping = inMapping;
		_factory = inFactory;
	}

	private function create() : IPropertiesMapper
	{
		var mapper : SimplePropertiesMapper = _factory.newInstance();
		mapper.mapping = _mapping;
		mapper.target = _target;
		mapper.strict = _strict;
		return mapper;
	}
	
	public function map(inSource:Object, inTarget:Object=null):*
	{
		
		var mapper : IPropertiesMapper = create();
		var out : * = mapper.map( inSource, _target );
		_factory.release( mapper );
		return out;
	}
	
	public function set mapFailDelegate(inFunction:Function):void
	{
	}
	
	public function mapWith(inSource:Object, inMapping:Object, inTarget:Object=null):*
	{
		var mapper : IPropertiesMapper = create();
		var out : * = mapper.mapWith( inSource, inMapping, _target );
		_factory.release( mapper );
		return out;
	}
	
	public function set strict(inValue:Boolean):void
	{
	}
	
	public function set targetClass(inClass:IFactory):void
	{
	}
}