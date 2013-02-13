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
package org.astoolkit.commons.eval
{

	import mx.core.IMXMLObject;
	import org.astoolkit.commons.conditional.api.IExpressionResolver;
	import org.astoolkit.commons.wfml.api.IChildrenAwareDocument;
	import org.astoolkit.commons.wfml.api.IComponent;

	[DefaultProperty("expression")]
	public class Resolve implements IComponent, IExpressionResolver, IMXMLObject
	{
		private var _destination : *;

		private var _pid : String;

		protected var _delegate : IExpressionResolver;

		protected var _document : Object;

		protected var _expression : Object;

		public function set delegate( inValue : IExpressionResolver ) : void
		{
			_delegate  = inValue;
		}

		public function set expression( inValue : Object ) : void
		{
			_expression = inValue;
		}

		public function set key( inValue : * ) : void
		{
			_destination = inValue;
		}

		public function get pid() : String
		{
			return _pid;
		}

		public function set pid( inValue : String ) : void
		{
			_pid = inValue;
		}

		public function bindToEnvironment( inEnv : Object, inExpression : Object ) : Object
		{
			return null;
		}

		public function initialized( inDocument : Object, inId : String ) : void
		{
			if( _document )
				return;
			_document = inDocument;

			if( _document is IChildrenAwareDocument )
				IChildrenAwareDocument( _document ).childNodeAdded( this );

		}

		public function resolve( inExpression : Object = null, inSource : Object = null ) : ExpressionResolverResult
		{

			var expr : Object = _expression ? _expression : inExpression;
			var src : Object = inSource ? inSource : _document;

			if( !_document || !( expr is String ) )
				return null;

			var out : ExpressionResolverResult;

			if( expr == "." )
			{
				out = new ExpressionResolverResult();
				out.result = src;
				out.source = src;
				return out;
			}

			if( _delegate )
			{
				out = _delegate.resolve( expr, src );

				if( out != null && out.result !== undefined )
					return out;
			}

			if( out == null )
				out = new ExpressionResolverResult();

			var dest : * = src;

			for each( var segment : String in String( expr ).split( "." ) )
			{
				dest = dest[ segment ];
			}
			out.result = dest;
			return out;
		}
	}
}
