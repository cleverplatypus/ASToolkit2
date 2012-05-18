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

package org.astoolkit.commons.io.transform.api
{
	public interface IIODataTransform
	{
		/**
		 * evaluates the inExpression content and transforms the inDataObject.
		 * 
		 * @param inExpression the transformation expression
		 * @param inData the object to be transformed
		 * @param inTarget (optional) the object calling the transform method
		 *  
		 * @return the transforming result
		 */
		function transform( inData : Object, inExpression : Object, inTarget : Object = null ) : Object
		/**
		 * an int for ordering transforming priorities.
		 */
		function get priority() : int;
		/**
		 * the list of types that can be used as sources (inData) for
		 * the <code>transform()</code> method
		 */ 
		function get supportedDataTypes() : Vector.<Class>;
		
		/**
		 * the list of types that can be used as transform descriptor (inExpression) for
		 * the <code>transform()</code> method
		 */ 
		function get supportedFilterTypes() : Vector.<Class>;
		
		/**
		 * returns true if the passed transform data is successfully
		 * validated (e.g. expression syntax checks)
		 */
		function isValidFilter( inExpression : Object ) : Boolean;
		
	}
}