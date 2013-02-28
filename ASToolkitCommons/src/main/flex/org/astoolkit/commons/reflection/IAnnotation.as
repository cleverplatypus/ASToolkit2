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

	import org.astoolkit.commons.io.transform.api.IIODataTransformer;

	public interface IAnnotation
	{
		function getArray( inArgName : String = "", inOrDefault : Boolean = false ) : Array;
		function getBoolean( inArgName : String = "", inOrDefault : Boolean = false ) : Boolean;
		function getClass( inArgName : String = "", inOrDefault : Boolean = false ) : Class;
		function getNumber( inArgName : String = "", inOrDefault : Boolean = false ) : Number;
		function getString( inArgName : String = "", inOrDefault : Boolean = false ) : String;
		function initialize( inMetadata : XML ) : void;
		function get tagName() : String;
		function validate() : Boolean;
	}
}
