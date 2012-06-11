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

	public class ClassInfo extends BaseInfo
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

		public static function forType( inClass : Object ) : ClassInfo
		{
			var n : String = getQualifiedClassName( inClass );

			if( !_classes.hasOwnProperty( n ) )
				_classes[ n ] = ClassInfo.create( inClass );
			return _classes[ n ] as ClassInfo;
		}

		private static function create( inClass : Object ) : ClassInfo
		{
			var xml : XML = describeType( inClass );
			var info : ClassInfo = new ClassInfo();
			info._isDynamic = xml.@isDynamic.toString() == "true";
			info._fullName = xml.@name.toString();

			if( inClass is Class )
				info._type = inClass as Class;
			else
				info._type = inClass.constructor;
			info._name = info._fullName.match( "::" ) ? info._fullName.split( "::" )[ 1 ] : info._fullName;
			info._annotations =
				AnnotationUtil.getAnnotationsFromMetadata(
				xml.factory.length() > 0 ?
				xml.factory.metadata :
				xml.metadata );

			if( xml.factory.length() > 0 )
			{
				if( xml.factory.extendsClass.length() > 0 )
					info._superClass = ClassInfo.forType( getDefinitionByName( xml.factory.extendsClass[ 0 ].@type.toString() ) );
			}
			else
				info._superClass = ClassInfo.forType( getDefinitionByName( xml.extendsClass[ 0 ].@type.toString() ) );

			if( info._superClass )
			{
				info._superClass._subClasses.push( info );
			}
			var contracts : XMLList = xml..implementsInterface;

			for each( var contractNode : XML in contracts )
			{
				var contract : ClassInfo = ClassInfo.forType( getDefinitionByName( contractNode.@type.toString() ) );
				info._interfacesByName[ contract.fullName ] = contract;
				info._interfaces.push( contract );
				contract._implementors.push( info );
			}

			for each( var annotation : IAnnotation in info._annotations )
			{
				if( !info._annotationsForName.hasOwnProperty( annotation.tagName ) )
					info._annotationsForName[ annotation.tagName ] =
						new Vector.<IAnnotation>();
				info._annotationsForName[ annotation.tagName ].push( annotation );

				if( !info._annotationsForType.hasOwnProperty( getQualifiedClassName( annotation ) ) )
					info._annotationsForType[ getQualifiedClassName( annotation ) ] =
						new Vector.<IAnnotation>();
				info._annotationsForType[ getQualifiedClassName( annotation ) ].push( annotation );
			}

			for each( var accessor : XML in xml.descendants().( name().toString() == "accessor" || name().toString() == "variable" ) )
			{
				var type : Class = accessor.@type.toString() == "*" ?
					Object : getDefinitionByName( accessor.@type.toString() ) as Class;
				var scope : String = accessor.@uri.toString() ==
					"http://www.adobe.com/2006/flex/mx/internal" ?
					FieldInfo.SCOPE_INTERNAL : FieldInfo.SCOPE_PUBLIC;
				info._fields[ accessor.@name.toString() ] =
					FieldInfo.create(
					accessor.@name.toString(),
					type,
					accessor.@access.toString() == "readonly",
					accessor.@access.toString() == "writeonly",
					scope,
					AnnotationUtil.getAnnotationsFromMetadata( accessor.metadata ) );
			}
			return info;
		}

		private var _fields : Object = {};

		private var _fullName : String;

		private var _implementors : Vector.<ClassInfo> = new Vector.<ClassInfo>();

		private var _interfaces : Vector.<ClassInfo> = new Vector.<ClassInfo>();

		private var _interfacesByName : Object = {};

		private var _methods : Object = {};

		private var _subClasses : Vector.<ClassInfo> = new Vector.<ClassInfo>();

		private var _superClass : ClassInfo;

		private var _type : Class;

		public function get fullName() : String
		{
			return _fullName;
		}

		public function getField( inName : String ) : FieldInfo
		{
			if( !_fields.hasOwnProperty( inName ) )
				return null;
			return _fields[ inName ] as FieldInfo;
		}

		public function getFields() : Vector.<FieldInfo>
		{
			var out : Vector.<FieldInfo> = new Vector.<FieldInfo>();

			for each( var f : FieldInfo in _fields )
				out.push( f );
			return out;
		}

		public function getFieldsWithAnnotation( inValue : Object ) : Vector.<FieldInfo>
		{
			var out : Vector.<FieldInfo> = new Vector.<FieldInfo>();

			for each( var field : FieldInfo in _fields )
			{
				if( field.hasAnnotation( inValue ) )
					out.push( field );
			}
			return out;
		}

		public function getInterfaceByName( inName : String ) : ClassInfo
		{
			if( _interfacesByName.hasOwnProperty( inName ) )
				return _interfacesByName[ inName ];
			return null;
		}

		public function getInterfacesBySuper( inSuper : Class ) : Vector.<ClassInfo>
		{
			var superInfo : ClassInfo = ClassInfo.forType( inSuper );
			var out : Vector.<ClassInfo> = new Vector.<ClassInfo>();

			for each( var contract : ClassInfo in _interfaces )
			{
				if( contract.fullName == superInfo.fullName ||
					contract.getInterfaceByName( superInfo.fullName ) )
					out.push( contract );
			}
			return out;
		}

		public function getInterfacesWithAnnotationsOfType( inAnnotationClass : Class ) : Vector.<ClassInfo>
		{
			var out : Vector.<ClassInfo> = new Vector.<ClassInfo>();

			for each( var contract : ClassInfo in _interfaces )
			{
				if( contract.hasAnnotation( inAnnotationClass ) )
					out.push( contract );
			}
			return out;
		}

		public function get interfaces() : Vector.<ClassInfo>
		{
			return _interfaces;
		}

		public function get methods() : Object
		{
			return _methods;
		}

		public function get type() : Class
		{
			return _type;
		}
	}
}
