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
package org.astoolkit.workflow.plugin.eval
{

	import com.hurlant.eval.ByteLoader;
	import com.hurlant.eval.CompiledESC;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	import org.astoolkit.commons.conditional.AsyncExpressionToken;
	import org.astoolkit.commons.conditional.BaseConditionalExpression;
	import org.astoolkit.commons.eval.api.IRuntimeExpressionEvaluator;

	public class Eval extends BaseConditionalExpression implements IRuntimeExpressionEvaluator
	{
		public static var env : Object;

		public static var handler : *;

		public static var instances : Object = {};

		private static var _esc : CompiledESC = new CompiledESC();

		public function Eval()
		{
			_id = "Eval_" + ( new Date() ).time;
			_instanceName = "Eval.instances." + _id;
		}

		private var _handler : Function;

		private var _id : String;

		private var _instanceData : InstanceData;

		private var _instanceName : String;

		private var _priority : int = -100;

		private var _text : String;

		private var _token : AsyncExpressionToken;

		override public function get async() : Boolean
		{
			return true;
		}

		public function eval() : Object
		{
			return evaluate();
		}

		override public function evaluate( inComparisonValue : * = undefined ) : Object
		{
			super.evaluate();

			if( !_instanceData )
			{
				_instanceData = new InstanceData();
				instances[ _id ] = _instanceData;
			}

			if( _instanceData.handler == null )
			{
				_instanceData.env = {};
				var exp : String = "namespace ev=\"org.astoolkit.workflow.plugin.eval\";\n" +
					"use namespace ev;\n" +
					_instanceName + ".handler = function() : *\n" +
					"{\n" +
					"try {\n" +
					"return " + _text.replace( /^\s+/, "" ) +
					";\n} catch( expressionError : Error ) \n{\n" +
					"return expressionError;\n" +
					"}\n" +
					"return false;\n" +
					"}\n";
				exp = _resolver.bindToEnvironment( _instanceData.env, exp ) as String;
				exp = exp.replace( /\$ENV\{\s*?[\$\w]+(\.[\$\w]+)*\s*?\}/g, replaceEnvPlaceHolders );

				try
				{
					var bytes : ByteArray = _esc.eval( exp );
					ByteLoader.loadBytes( bytes ).contentLoaderInfo.addEventListener( Event.INIT, onEvalDone );
					_token = new AsyncExpressionToken();
					return _token;
				}
				catch( e : Error )
				{
					return new Error( "Error evaluating expression \"" + _text + "\"\nRoot cause: " + e.getStackTrace() );
				}
			}
			else
			{
				_lastResult =
					_instanceData.handler();
				return _lastResult;
			}
			return null;
		}

		override public function invalidate() : void
		{
			if( _instanceData )
				_instanceData.handler = null;
			_lastResult = undefined;
		}

		public function get priority() : int
		{
			return _priority;
		}

		public function set priority( inValue : int ) : void
		{
			_priority = inValue;
		}

		public function set runtimeExpression( inValue : String ) : void
		{
			_text = inValue;
		}

		public function supportsExpression( inExpression : String ) : Boolean
		{
			return true;
		}

		public function set text( value : String ) : void
		{
			_text = value;

			if( _instanceData )
				_instanceData.handler = null;
		}

		private function onEvalDone( inEvent : Event ) : void
		{

			var result : * = _instanceData.handler()


			if( result is Boolean || result is Error )
				_lastResult = result;

			if( result is Function )
				_lastResult = result();
			else
				_lastResult = new Error( "Eval expression must be ether a " +
					"Boolean or a function returning a boolean" );
			_token.complete( result );
		}

		private function replaceEnvPlaceHolders(
			inFoundText : String,
			inPosition : int,
			inWholeText : String, ... rest ) : String
		{
			return _instanceName + ".env." + inFoundText.match( /^\$ENV\{\s*?([\$\w]+(\.[\$\w]+)*)/ )[ 1 ];
		}
	}

}

class InstanceData
{
	public var env : Object;

	public var handler : Function;
}
