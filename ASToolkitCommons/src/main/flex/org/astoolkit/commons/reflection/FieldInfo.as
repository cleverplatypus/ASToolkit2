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

	import flash.sampler.Sample;
	import flash.utils.getQualifiedClassName;

	public class FieldInfo extends BaseInfo
	{
		public static const SCOPE_INTERNAL : String = "internal";

		public static const SCOPE_PUBLIC : String = "public";

		public static function create(
			inName : String,
			inType : Class,
			inReadOnly : Boolean,
			inWriteOnly : Boolean,
			inScope : String,
			inAnnotations : Vector.<IAnnotation>,
			inOwner : ClassInfo,
			inDeclarer : ClassInfo ) : FieldInfo
		{
			var i : FieldInfo = new FieldInfo();
			i._name = inName;
			i._readOnly = inReadOnly;
			i._writeOnly = inWriteOnly;
			i._scope = inScope;
			i._type = inType;
			i._annotationsForName = {};
			i._annotations = inAnnotations.concat();
			i._owner = inOwner;
			i._local = inOwner == inDeclarer;
			i._declarer = inDeclarer;

			for each( var annotation : IAnnotation in inAnnotations )
			{
				if( !i._annotationsForName.hasOwnProperty( annotation.tagName ) )
					i._annotationsForName[ annotation.tagName ] =
						new Vector.<IAnnotation>();
				i._annotationsForName[ annotation.tagName ].push( annotation );

				if( !i._annotationsForType.hasOwnProperty( getQualifiedClassName( annotation ) ) )
					i._annotationsForType[ getQualifiedClassName( annotation ) ] =
						new Vector.<IAnnotation>();
				i._annotationsForType[ getQualifiedClassName( annotation ) ].push( annotation );
			}
			return i;
		}

		private var _declarer : ClassInfo;

		private var _local : Boolean;

		private var _owner : ClassInfo;

		private var _readOnly : Boolean;

		private var _scope : String;

		private var _type : Class;

		private var _writeOnly : Boolean;

		public function get fullAccess() : Boolean
		{
			return !_readOnly && !_writeOnly;
		}

		public function get readOnly() : Boolean
		{
			return _readOnly;
		}

		public function get scope() : String
		{
			return _scope;
		}

		public function get type() : Class
		{
			return _type;
		}

		public function get writeOnly() : Boolean
		{
			return _writeOnly;
		}
	}
}
