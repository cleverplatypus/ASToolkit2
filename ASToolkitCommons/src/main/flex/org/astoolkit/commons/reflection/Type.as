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
package org.astoolkit.commons.reflection
{

	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	import org.astoolkit.commons.utils.ObjectCompare;

	public class Type extends AbstractReflection
	{
		private static var _classes : Object = {};

		private static var _willClearCache : Boolean;

		public static function clearCache( inDefer : Boolean = false ) : void
		{
			if( !inDefer )
			{
				_classes = {};
				_willClearCache = false;
			}
			else
			{
				if( !_willClearCache )
					setTimeout( clearCache, 1, false );
			}
		}

		public static function forType( inClass : Object ) : Type
		{
			var n : String = getQualifiedClassName( inClass );

			if( !_classes.hasOwnProperty( n ) )
			{
				_classes[ n ] = Type.create( inClass );
				Type( _classes[ n ] ).init();
			}
			return _classes[ n ] as Type;
		}

		private static function create( inClass : Object ) : Type
		{
			var info : Type = new Type();

			if( inClass is Class )
				info._type = inClass as Class;
			else
				info._type = getDefinitionByName( getQualifiedClassName( inClass ) ) as Class;
			return info;
		}

		private var _fields : Object = {};

		private var _fullName : String;

		private var _implementors : Vector.<Type> = new Vector.<Type>();

		private var _interfaces : Vector.<Type> = new Vector.<Type>();

		private var _interfacesByName : Object = {};

		private var _methods : Object = {};

		private var _subClasses : Vector.<Type> = new Vector.<Type>();

		private var _subtype : Class;

		private var _subtypeInfo : Type;

		private var _superClass : Type;

		private var _type : Class;

		public function get fullName() : String
		{
			return _fullName;
		}

		public function get interfaces() : Vector.<Type>
		{
			return _interfaces;
		}

		public function get methods() : Object
		{
			return _methods;
		}

		public function get superClass() : Type
		{
			return _superClass;
		}

		public function get type() : Class
		{
			return _type;
		}

		public function getField( inName : String ) : Field
		{
			if( !_fields.hasOwnProperty( inName ) )
				return null;
			return _fields[ inName ] as Field;
		}

		public function getFields() : Vector.<Field>
		{
			var out : Vector.<Field> = new Vector.<Field>();

			for each( var f : Field in _fields )
				out.push( f );
			return out;
		}

		public function getFieldsWithAnnotation( inValue : Object ) : Vector.<Field>
		{
			var out : Vector.<Field> = new Vector.<Field>();

			for each( var field : Field in _fields )
			{
				if( field.hasAnnotation( inValue ) )
					out.push( field );
			}
			return out;
		}

		public function getInterfaceByName( inName : String ) : Type
		{
			if( _interfacesByName.hasOwnProperty( inName ) )
				return _interfacesByName[ inName ];
			return null;
		}

		public function getInterfacesBySuper( inSuper : Class ) : Vector.<Type>
		{
			var superInfo : Type = Type.forType( inSuper );
			var out : Vector.<Type> = new Vector.<Type>();

			for each( var contract : Type in _interfaces )
			{
				if( contract.fullName == superInfo.fullName ||
					contract.getInterfaceByName( superInfo.fullName ) )
					out.push( contract );
			}
			return out;
		}

		public function getInterfacesWithAnnotationsOfType( inAnnotationClass : Class ) : Vector.<Type>
		{
			var out : Vector.<Type> = new Vector.<Type>();

			for each( var contract : Type in _interfaces )
			{
				if( contract.hasAnnotation( inAnnotationClass ) )
					out.push( contract );
			}
			return out;
		}

		public function implementsInterface( inInterface : Class ) : Boolean
		{
			for each( var i : Type in _interfaces )
			{
				if( i.type == inInterface )
					return true;
			}
			return false;
		}

		private function init() : void
		{
			var aTypeText : String = getQualifiedClassName( _type );

			if( aTypeText.match( /Vector\.</ ) )
			{
				_subtype = getDefinitionByName( aTypeText.match( /<(.+?)>/ )[1] ) as Class;
				_subtypeInfo = Type.forType( _subtype );
			}
			var xml : XML = describeType( _type );
			_isDynamic = xml.@isDynamic.toString() == "true";
			_fullName = xml.@name.toString();

			_name = _fullName.match( "::" ) ? _fullName.split( "::" )[ 1 ] : _fullName;
			_annotations =
				AnnotationUtil.getAnnotationsFromMetadata(
				xml.factory.length() > 0 ?
				xml.factory.metadata :
				xml.metadata );

			if( xml.factory.length() > 0 )
			{
				try
				{
					if( xml.factory.extendsClass.length() > 0 )
					{
						var superType : String =  
							String( xml.factory.extendsClass[ 0 ].@type.toXMLString() )
							.replace( /&lt;/, '<' );

						if( superType == "__AS3__.vec::Vector.<*>" )
							_superClass = Type.forType( Vector );
						else
							_superClass = Type.forType( getDefinitionByName( superType ) );
					}
				}
				catch( e : Error )
				{
					trace( e.getStackTrace() );
				}
			}
			else
				_superClass = Type.forType( getDefinitionByName( xml.extendsClass[ 0 ].@type.toString() ) );

			if( _superClass )
			{
				_superClass._subClasses.push( this );
			}
			var contracts : XMLList = xml..implementsInterface;

			for each( var contractNode : XML in contracts )
			{
				var contract : Type = Type.forType( getDefinitionByName( contractNode.@type.toString() ) );
				_interfacesByName[ contract.fullName ] = contract;
				_interfaces.push( contract );
				contract._implementors.push( this );
			}

			for each( var annotation : IAnnotation in _annotations )
			{
				if( !_annotationsForName.hasOwnProperty( annotation.tagName ) )
					_annotationsForName[ annotation.tagName ] =
						new Vector.<IAnnotation>();
				_annotationsForName[ annotation.tagName ].push( annotation );

				if( !_annotationsForType.hasOwnProperty( getQualifiedClassName( annotation ) ) )
					_annotationsForType[ getQualifiedClassName( annotation ) ] =
						new Vector.<IAnnotation>();
				_annotationsForType[ getQualifiedClassName( annotation ) ].push( annotation );
			}

			for each( var accessor : XML in xml.descendants().( name().toString() == "accessor" || name().toString() == "variable" ) )
			{
				var declarer : Type =
					accessor.@declaredBy == fullName ?
					this : null;
				aTypeText = accessor.@type.toXMLString().replace( /&lt;/, '<' );
				var aType : Class;
				var aSubtype : Class;

				if( aTypeText == "*" )
				{
					aType = null;
				}
				else
				{
					aType = getDefinitionByName( aTypeText ) as Class;

					if( aTypeText.match( /Vector\.</ ) )
					{
						aSubtype = getDefinitionByName( aTypeText.match( /<(.+?)>/ )[1] ) as Class;
					}
				}
				var scope : String = accessor.@uri.toString() ==
					"http://www.adobe.com/2006/flex/mx/internal" ?
					Field.SCOPE_INTERNAL : Field.SCOPE_PUBLIC;
				_fields[ accessor.@name.toString() ] =
					Field.create(
					accessor.@name.toString(),
					aType,
					aSubtype,
					accessor.@access.toString() == "readonly",
					accessor.@access.toString() == "writeonly",
					scope,
					AnnotationUtil.getAnnotationsFromMetadata( accessor.metadata ),
					this,
					declarer
					);

			}
		}
	}
}
