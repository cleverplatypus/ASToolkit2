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

	import flash.utils.getQualifiedClassName;
	import mx.utils.StringUtil;
	import org.astoolkit.commons.conditional.api.IExpressionResolver;
	import org.astoolkit.commons.eval.Resolve;

	[DefaultProperty("selfWiringChildren")]
	public class MethodBuilder extends AbstractBuilder
	{

		public static function parse( inString : String ) : MethodBuilder
		{
			var out : MethodBuilder = new MethodBuilder();

			var methodName : String = inString.match( /\(.*\)$/ ) ?
				inString.replace( /\(.*$/, "" ) :
				inString;
			out.name = methodName;
			var args : Array = inString.match( /\(.+\)$/ ) ?
				StringUtil.trimArrayElements( inString.match( /\((.+?)\)/ )[1], "," ).split(",") : [];
			var resolvers : Vector.<IExpressionResolver> = new Vector.<IExpressionResolver>();
			var resolver : Resolve;

			for each( var arg : String in args )
			{
				resolver = new Resolve();
				resolver.expression = arg;
				resolvers.push( resolver );
			}
			out.arguments = resolvers;
			return out;
		}

		private var _name : String;

		private var _target : Object;

		[Featured]
		/**
		 * alias setter for _expressionResolvers property. For declaration clarity.
		 */
		public function get arguments() : Vector.<IExpressionResolver>
		{
			return _expressionResolvers;
		}

		public function set arguments( inValue : Vector.<IExpressionResolver> ) : void
		{
			_expressionResolvers = inValue;
		}

		public function get name() : String
		{
			return _name;
		}

		public function set name( inValue : String ) : void
		{
			_name = inValue;
		}

		public function set target( inValue : Object ) : void
		{
			_target = inValue;
		}

		override public function getData() : *
		{

			if( !_target || !_name )
				throw new Error( "Either or both _target and _name are not set" );

			if( !_target.hasOwnProperty( _name ) || !( _target[ _name ] is Function ) )
			{
				throw new Error( "\"" + _name + "\" is not a method of class " + 
					getQualifiedClassName( _target ) );
			}

			return function() : *
			{
				( _target[ _name ] as Function ).apply( _target, resolveArguments() ); 
			} as Function; //casting to prevent compiler warning
		}

		private function resolveArguments() : Array
		{
			var out : Array = [];

			for each( var resolver : IExpressionResolver in _expressionResolvers )
				out.push( resolver.resolve().result );
			return out;
		}
	}
}
