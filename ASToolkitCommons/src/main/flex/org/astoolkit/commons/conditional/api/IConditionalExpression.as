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
package org.astoolkit.commons.conditional.api
{

	import mx.core.IMXMLObject;

	public interface IConditionalExpression extends IMXMLObject
	{
		function get async() : Boolean;
		function clearResult() : void;
		function set delegate( inValue : Function ) : void;
		function evaluate( inComparisonValue : * = undefined ) : Object;
		function invalidate() : void;
		function get lastResult() : *;
		function get parent() : IConditionalExpressionGroup;
		function set parent( inValue : IConditionalExpressionGroup ) : void;
		function set resolver( inValue : IExpressionResolver ) : void;
	}
}
