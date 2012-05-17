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
package org.astoolkit.commons.io.filter
{
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.commons.io.filter.api.IIOFilter;

	public class FunctionReferenceTaskInputFilter implements IIOFilter
	{
				
		public function filter( inData : Object, inFilterData : Object, inTarget : Object = null ) : Object
		{
			return ( inFilterData as Function )( inData, inTarget );
		}
		
		public function isValidFilter( inFilterData : Object ) : Boolean
		{
			return inFilterData is Function; 
		}
		
		public function get priority():int
		{
			// TODO Auto Generated method stub
			return -100;
		}
		
		public function get supportedFilterTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( Function );
			return out;
		}
		
		public function get supportedDataTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			return out;
		}
		
	}
}