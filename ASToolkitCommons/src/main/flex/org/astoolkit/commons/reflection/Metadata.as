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

	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.StringUtil;

	import org.astoolkit.commons.io.transform.api.IIODataTransformer;
	import org.astoolkit.commons.utils.getLogger;

	public class Metadata implements IAnnotation
	{
		private static const LOGGER : ILogger = getLogger( Metadata );

		protected var _metadata : XML;

		protected var _ownerType : Class = Object;

		protected var _tagName : String;

		protected var _tagRepeatable : Boolean;

		protected var _target : Array;

		protected var _targetType : Class = Object;

		public function get ownerType() : Class
		{
			return _ownerType;
		}

		public function get tagName() : String
		{
			return _tagName;
		}

		public function get tagRepeatable() : Boolean
		{
			return _tagRepeatable;
		}

		public function get targetType() : Class
		{
			return _targetType;
		}

		public function Metadata()
		{
			var desc : XML = describeType( this );
			var meta : XML = desc.factory.length() > 0 ?
				desc.factory.metadata.( @name == "Metadata" )[ 0 ] :
				desc.metadata.( @name == "Metadata" )[ 0 ];

			if( !meta )
				return;

			if( meta.arg.( @key == "repeatable" ).length() > 0 )
			{
				_tagRepeatable = StringUtil.trim( meta.arg.( @key == "repeatable" ).@value.toString() ).toLowerCase() == "true";
			}

			if( meta.arg.( @key == "name" ).length() > 0 )
				_tagName = meta.arg.( @key == "name" ).@value.toString();
			else
				_tagName = getQualifiedClassName( this ).match( /([^:\.]+)$/ )[ 0 ];

			if( meta.@target.length() > 0 )
			{
				_target = StringUtil.trimArrayElements(
					meta.@target.toString(), "," )
					.split( "," );

				if( !_target.every(
					function(
					inVal : String,
						inIndex : int,
						inArray : Array ) : Boolean
						{
							return inVal == "interface" ||
								inVal == "class" ||
								inVal == "property" ||
								inVal == "getter" ||
								inVal == "setter" ||
								inVal == "function";
						} ) )
				{
					LOGGER.error(
						"Unknown metadata target '{0}' in '{1}'",
						meta.@target.toString(),
						getQualifiedClassName( this ) );
				}
			}
		}

		public function getArray( inArgName : String = "", inOrDefault : Boolean = false ) : Array
		{
			var stringValue : String = getString( inArgName, inOrDefault );

			if( stringValue )
				return StringUtil.trimArrayElements( stringValue, "," ).split( "," );
			return null;
		}

		public function getBoolean( inArgName : String = "", inOrDefault : Boolean = false ) : Boolean
		{
			var stringValue : String = getString( inArgName, inOrDefault );

			if( stringValue )
				return Boolean( stringValue );
			return false;
		}

		public function getClass( inArgName : String = "", inOrDefault : Boolean = false ) : Class
		{
			var stringValue : String = getString( inArgName, inOrDefault );

			if( stringValue )
			{
				try
				{
					return getDefinitionByName( stringValue ) as Class;
				}
				catch( e : Error )
				{
					return null;
				}
			}
			return null;
		}

		public function getNumber( inArgName : String = "", inOrDefault : Boolean = false ) : Number
		{
			var stringValue : String = getString( inArgName, inOrDefault );

			if( stringValue )
				return Number( stringValue );
			return NaN;
		}

		public function getString( inArgName : String = "", inOrDefault : Boolean = false ) : String
		{
			var arg : XMLList = _metadata.arg.( @key == inArgName );

			if( arg && arg.length() > 0 )
				return arg[ 0 ].@value.toString();
			else if( inOrDefault )
			{
				arg = _metadata.arg.( @key == "" );

				if( arg && arg.length() > 0 )
					return arg[ 0 ].@value.toString();
			}
			return null;
		}

		public function initialize( inMetadata : XML ) : void
		{
			_metadata = inMetadata;
		}

		public function validate() : Boolean
		{
			return true;
		}

	}
}
