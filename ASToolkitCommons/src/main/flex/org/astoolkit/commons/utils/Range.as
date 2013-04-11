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
package org.astoolkit.commons.utils
{
	import org.astoolkit.lang.util.getClass;

	public class Range
	{
		public static function create( inFrom : *, inTo : * ) : Range
		{
			if( inFrom == null || inTo == null )
				throw new Error( "Range from and to types must not be null" );
			var termsType : Class = getClass( inFrom );

			if( termsType != getClass( inTo ) )
				throw new Error( "Range from and to types must match" );
			var out : Range = new Range();
			out._from = inFrom;
			out._to = inTo;
			out._termsType = termsType;
			return out;
		}

		private var _from : *;

		private var _termsType : Class;

		private var _to : *;

		public function get from() : *
		{
			return _from;
		}

		public function get termsType() : Class
		{
			return _termsType;
		}

		public function get to() : *
		{
			return _to;
		}
	}
}
