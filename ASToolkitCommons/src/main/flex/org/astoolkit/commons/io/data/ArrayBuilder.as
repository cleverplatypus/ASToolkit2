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
	import org.astoolkit.commons.io.data.api.IDataBuilder;
	import org.astoolkit.commons.wfml.autoassign.AutoAssignUtil;
	import org.astoolkit.commons.configuration.api.ISelfWiring;
	import org.astoolkit.commons.wfml.api.IComponent;

	[DefaultProperty( "selfWiringChildren" )]
	public class ArrayBuilder implements IDataBuilder, IComponent, ISelfWiring
	{
		private var _selfWiringChildren : Array;

		private var _document : Object;

		private var _expressionResolvers : Vector.<IExpressionResolver>;

		private var _pid : String;

		public function set selfWiringChildren( inValue : Array ) : void
		{
			_selfWiringChildren = inValue;
		}

		[AutoAssign]
		public function set expressionResolvers( inValue : Vector.<IExpressionResolver> ) : void
		{
			_expressionResolvers = inValue;
		}

		public function get pid() : String
		{
			return _pid;
		}

		public function set pid( inValue : String ) : void
		{
			_pid = inValue;
		}

		public function get builtDataType() : Class
		{
			return Array;
		}

		public function getData() : *
		{
			var out : Array = [];

			if( _expressionResolvers )
			{
				for each( var resolver : IExpressionResolver in _expressionResolvers )
				{
					out.push( resolver.resolve( null, _document ).result );
				}
			}
			return out;
		}

		public function initialized( inDocument : Object, inId : String ) : void
		{
			_document = inDocument;
			AutoAssignUtil.autoAssign( this, _selfWiringChildren );
		}
	}
}
