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
	
	import org.osmf.metadata.Metadata;

	public class ClassInfo extends BaseInfo
	{
		private static var _willClearCache : Boolean;
		private static var _classes : Object = {};
		
		private var _fields : Object = {};
		private var _fullName : String;
		private var _methods : Object = {};		

		public function getField( inName : String ) : FieldInfo
		{
			if( !_fields.hasOwnProperty( inName ) )
				return null;
			return _fields[inName ] as FieldInfo;
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
		
		public function getFields() : Vector.<FieldInfo>
		{
			var out : Vector.<FieldInfo> = new Vector.<FieldInfo>();
			for each( var f : FieldInfo in _fields )
				out.push( f );
			return out;
		}
		
		private static function create( inClass : Object ) : ClassInfo
		{
			var xml : XML = describeType( inClass );
			var info : ClassInfo = new ClassInfo();
			
			info._isDynamic = xml.@isDynamic.toString() == "true";
			info._fullName = xml.@name.toString();
			info._name = info._fullName.match( "::" ) ? info._fullName.split( "::" )[1] : info._fullName;
			info._annotations = AnnotationUtil.getAnnotationsFromMetadata( xml.metadata );
			
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

			for each( var accessor : XML in xml.children().( name().toString() == "accessor" || name().toString() == "variable" )  )
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
		
		public static function forType( inClass : Object ) : ClassInfo
		{
			var n : String = getQualifiedClassName( inClass );
			
			if( !_classes.hasOwnProperty( n ) )
				_classes[ n ] = ClassInfo.create( inClass );
			
			return _classes[ n ] as ClassInfo;
		}

		public function get fullName():String
		{
			return _fullName;
		}

		public function get methods():Object
		{
			return _methods;
		}

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
		
		

		
	}
}