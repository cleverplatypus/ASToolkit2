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

	import org.astoolkit.commons.conditional.api.IExpressionResolver;

	[DefaultProperty( "selfWiringChildren" )]
	public class ObjectBuilder extends AbstractBuilder
	{
		public function set type( inValue : Class ) : void
		{
			_providedType = inValue;
		}

		override public function getData() : *
		{
			var localType : Class = _providedType ? _providedType : Object;

			var target : Object = new localType();

			for each( var resolver : IExpressionResolver in _expressionResolvers )
			{
				if( !resolver.key )
					throw new Error( "Resolvers must have a key in ObjectBuilder" );
				target[ resolver.key ] = resolver.resolve().result;
			}
			return target;
		}


	}
}
