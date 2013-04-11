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

	import flash.sampler.Sample;
	import flash.utils.getQualifiedClassName;
	import org.astoolkit.lang.reflection.api.IAnnotation;

	public class Field extends AbstractReflection
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
			inOwner : Type,
			inDeclarer : Type ) : Field
		{
			var outField : Field = new Field();
			outField._name = inName;
			outField._readOnly = inReadOnly;
			outField._writeOnly = inWriteOnly;
			outField._scope = inScope;
			outField._type = inType;
			outField._annotationsForName = {};
			outField._annotations = inAnnotations.concat();
			outField._owner = inOwner;
			outField._local = inOwner == inDeclarer;
			outField._declarer = inDeclarer;

			for each( var annotation : IAnnotation in inAnnotations )
			{
				if( !outField._annotationsForName.hasOwnProperty( annotation.tagName ) )
					outField._annotationsForName[ annotation.tagName ] =
						new Vector.<IAnnotation>();
				outField._annotationsForName[ annotation.tagName ].push( annotation );

				if( !outField._annotationsForType.hasOwnProperty( getQualifiedClassName( annotation ) ) )
					outField._annotationsForType[ getQualifiedClassName( annotation ) ] =
						new Vector.<IAnnotation>();
				outField._annotationsForType[ getQualifiedClassName( annotation ) ].push( annotation );
			}
			return outField;
		}

		private var _declarer : Type;

		private var _local : Boolean;


		private var _readOnly : Boolean;

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


		/*public function get subtype() : Class
		{
			return _subtype;
		}*/

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
