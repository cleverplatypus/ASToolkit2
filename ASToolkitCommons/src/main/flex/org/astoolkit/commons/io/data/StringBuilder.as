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
package org.astoolkit.commons.io.data
{

	import mx.utils.StringUtil;
	import org.astoolkit.commons.conditional.api.IExpressionResolver;
	import org.astoolkit.commons.io.data.api.IDataProvider;
	import org.astoolkit.commons.process.api.IDeferrableProcess;
	import org.astoolkit.commons.reflection.AutoConfigUtil;
	import org.astoolkit.commons.wfml.IAutoConfigContainerObject;
	import org.astoolkit.commons.wfml.IComponent;

	[DefaultProperty("autoConfigChildren")]
	public class StringBuilder extends AbstractBuilder
	{
		private var _source : String;

		public function set source( inValue : String ) : void
		{
			_source = inValue;
		}

		override public function getData() : *
		{
			var out : String = _source;

			if( _expressionResolvers )
			{
				var params : Array = [ _source ]

				for each( var resolver : IExpressionResolver in _expressionResolvers )
				{
					params.push( resolver.resolve( null, _document ).result );
				}
				out = StringUtil.substitute.apply( null, params );
			}
			return out;
		}
	}
}
