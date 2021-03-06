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
package org.astoolkit.commons.conditional
{

	import org.astoolkit.commons.utils.ObjectCompare;

	public class Gt extends BaseConditionalExpression
	{
		public var base : *;

		public var than : *;

		override public function evaluate( inComparisonValue : * = undefined ) : Object
		{
			if( _lastResult !== undefined )
				return _lastResult;
			var compared : * = base === undefined ? resolveSource( inComparisonValue ) : base;
			_lastResult = negateSafeResult( ObjectCompare.compare( compared, than ) == 1 );
			return _lastResult;
		}
	}
}
