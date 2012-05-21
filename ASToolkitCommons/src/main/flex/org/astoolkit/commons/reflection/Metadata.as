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
	
	import mx.utils.StringUtil;
	
	import org.astoolkit.commons.io.transform.api.IIODataTransform;
	
	public class Metadata implements IAnnotation
	{
		protected var _metadata : XML;
		protected var _tagName : String;
		protected var _target : String;
		
		public function initialize( inMetadata : XML ) : void
		{
			_metadata = inMetadata;
			_tagName = _metadata.@name.toString();
			//TODO: add checks for [MetaArg]
		}
		
		public function get tagName() : String
		{
			return _tagName;
		}
		
		public function getArray( inArgName : String = "" ) : Array
		{
			var s : String = getString( inArgName );
			if( s )
				return s.split( "," ).map( 
					function callback(inItem:String, inIndex:int, inArray:Array) : String
					{
						return StringUtil.trim( inItem );
					});
			return null;
		}
		
		public function getBoolean( inArgName : String = "" ) : Boolean
		{
			var s : String = getString( inArgName );
			if( s )
				return Boolean( s );
			return false;

		}
		
		public function getFilter( inArgName : String = "" ) : IIODataTransform
		{
			// TODO Auto Generated method stub
			return null;
		}
		
		public function getNumber( inArgName : String = "" ) : Number
		{
			var s : String = getString( inArgName );
			if( s )
				return Number( s );
			return NaN;
		}
		
		public function getString( inArgName : String = "" ) : String
		{
			var arg : XMLList = _metadata.arg.(@key == inArgName );
			if( arg && arg.length() > 0 )
				return arg[0].@value.toString();
			return null;
		}
		
		
	}
}