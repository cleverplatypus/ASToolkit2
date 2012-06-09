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
	
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import mx.core.IFactory;
	import mx.utils.ObjectUtil;
	import org.astoolkit.commons.io.transform.DefaultDataTransformRegistry;
	import org.astoolkit.commons.io.transform.api.IIODataTransformer;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	import org.astoolkit.commons.utils.isDynamic;
	
	public class SimplePropertiesMapper implements IPropertiesMapper
	{
		public var mapping : Object;
		
		private var _classFactory : IFactory;
		
		private var _strict : Boolean = false;
		
		private var _failDelegate : Function;
		
		private var _target : Object;
		
		private var _transformerRegistry : IIODataTransformerRegistry;
		
		public function set transformerRegistry( inValue : IIODataTransformerRegistry ) : void
		{
			_transformerRegistry = inValue;
		}
		
		public function hasTarget() : Boolean
		{
			return _target != null;
		}
		
		public function set mapFailDelegate( inFunction : Function ) : void
		{
			_failDelegate = inFunction;
		}
		
		public function set target( inValue : Object ) : void
		{
			_target = inValue;
		}
		
		public function set targetClass( inClassFactory : IFactory ) : void
		{
			_classFactory = inClassFactory
		}
		
		public function set strict( inValue : Boolean ) : void
		{
			_strict = inValue;
		}
		
		public function map( inSource : Object, inTarget : Object = null ) : *
		{
			return mapWith( inSource, mapping, _target != null ? _target : inTarget );
		}
		
		public function mapWith( 
			inSource : Object, 
			inMapping : Object, 
			inTarget : Object = null ) : *
		{
			if ( !_transformerRegistry )
			{
				_transformerRegistry = new DefaultDataTransformRegistry();
			}
			var localTarget : Object = inTarget;
			
			if ( !localTarget )
				localTarget = _target;
			
			if ( !localTarget )
				localTarget = _classFactory ? _classFactory.newInstance() : {};
			var isDynamicTarget : Boolean = isDynamic( localTarget );
			var transformer : IIODataTransformer;
			var value : *;
			
			for ( var k : String in inMapping )
			{
				try
				{
					transformer = _transformerRegistry.getTransformer( inSource, inMapping[ k ] );
					value = transformer.transform( inSource, inMapping[ k ] )
					localTarget[ k ] = value;
				}
				catch ( e : Error )
				{
					if ( _strict )
					{
						var className : String = getQualifiedClassName( !inSource.hasOwnProperty( inMapping[ k ] ) ? inSource : localTarget );
						var propName : String = !inSource.hasOwnProperty( inMapping[ k ] ) ? inMapping[ k ] : k;
						throw new MappingError( className + " has no \"" + propName + "\" property" );
					}
					else
					{
						if ( _failDelegate is Function )
							_failDelegate( k );
						continue;
					}
				}
				/*				if ( ( inMapping[ k ] == "." || localTarget.hasOwnProperty( k ) || isDynamicTarget ) )
								{
								try
								{
										if ( inMapping[ k ] == "." )
											localTarget[ k ] = inSource;
										else
											localTarget[ k ] = inSource[ inMapping[ k ] ];
									}
									catch ( e : Error )
									{
										if ( _strict )
										{
											var className : String = getQualifiedClassName( !inSource.hasOwnProperty( inMapping[ k ] ) ? inSource : localTarget );
											var propName : String = !inSource.hasOwnProperty( inMapping[ k ] ) ? inMapping[ k ] : k;
											throw new MappingError( className + " has no \"" + propName + "\" property" );
										}
										else
										{
											if ( _failDelegate is Function )
												_failDelegate( k );
											continue;
										}
									}
								}
				*/
			}
			
			if ( inTarget == null && _target == null )
				return localTarget;
		}
	}
}
