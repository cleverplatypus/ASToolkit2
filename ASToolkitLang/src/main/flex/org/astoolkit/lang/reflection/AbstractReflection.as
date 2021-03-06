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
package org.astoolkit.lang.reflection
{

	import flash.utils.getQualifiedClassName;

	import org.astoolkit.lang.reflection.api.IASSymbol;
	import org.astoolkit.lang.reflection.api.IAnnotation;

	internal class AbstractReflection implements IASSymbol
	{
		protected var _annotations : Vector.<IAnnotation>;

		protected var _annotationsForName : Object = {};

		protected var _annotationsForType : Object = {};

		protected var _isDynamic : Boolean;

		protected var _name : String;

		protected var _scope : String;

		public function get owner() : Type
		{
			return _owner;
		}


		protected var _isStatic : Boolean;

		protected var _owner : Type;

		public function AbstractReflection()
		{
			if( getQualifiedClassName( this ).match( /\:\:AbstractReflection$/ ) )
				throw new Error( "AbstractReflection cannot be instanciated" );
		}

		public function get scope() : String
		{
			return _scope;
		}

		public function get annotations() : Vector.<IAnnotation>
		{
			return _annotations;
		}

		public function getAnnotationsOfType( inClass : Class ) : Vector.<IAnnotation>
		{
			if( _annotationsForType.hasOwnProperty( getQualifiedClassName( inClass ) ) )
				return _annotationsForType[ getQualifiedClassName( inClass ) ];
			return null;
		}

		public function getAnnotationsWithName( inName : String ) : Vector.<IAnnotation>
		{
			if( _annotationsForType.hasOwnProperty( inName ) )
				return _annotationsForType[ inName ];
			return null;
		}

		public function hasAnnotation( inValue : Object ) : Boolean
		{
			if( inValue is String )
				return _annotationsForName.hasOwnProperty( inValue );
			else if( inValue is Class )
				return _annotationsForType.hasOwnProperty( getQualifiedClassName( inValue ) );
			return false;
		}

		public function get isDynamic() : Boolean
		{
			return _isDynamic;
		}

		public function get name() : String
		{
			return _name;
		}

		public function get isStatic() : Boolean
		{
			return _isStatic;
		}

	}
}
