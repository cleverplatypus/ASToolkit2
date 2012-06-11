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
package org.astoolkit.workflow.task.log
{

	import flash.utils.getQualifiedClassName;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.utils.ObjectUtil;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Writes to the currently registered Logger instances at the specified level
	 * <p>
	 * <b>Input</b>
	 * <ul>
	 * <li>a value to be logged. If a non-String is passed,
	 * <code>ObjectUtil.toString( value )</code> is used</li>
	 * </ul>
	 * <b>No Output</b>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>message</code> (injectable): the message to be logged </li>
	 * <li><code>parameters</code> an optional array of parameters to be used for string substitution in the message</li>
	 * <li><code>level</code>: either debug,info,warn,error or fatal </li>
	 * </ul>
	 * </p>
	 */
	public class WriteLog extends BaseTask
	{
		private static const LOGGER : ILogger =
			Log.getLogger( getQualifiedClassName( WriteLog ).replace( /:+/g, "." ) );

		[Inspectable( defaultValue="debug", enumeration="debug,info,warn,error,fatal" )]
		/**
		 * debug level.
		 * <p>Either debug,info,warn,error or fatal</p>
		 */
		public var level : String = "debug";

		[Bindable]
		[InjectPipeline]
		/**
		 * the text to log.
		 * <p>{<em>n</em>} placeholders can be used for text substitution.</p>
		 */
		public var message : String = null;

		/**
		 * parameters for text substitution in the message
		 */
		public var parameters : Array = [];

		/**
		 * @private
		 */
		private var _levels : Object =
			{
				debug: LogEventLevel.DEBUG,
				info: LogEventLevel.INFO,
				warn: LogEventLevel.WARN,
				error: LogEventLevel.ERROR,
				fatal: LogEventLevel.FATAL
			};

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			try
			{
				var outMessage : String = message;

				if( !outMessage )
				{
					outMessage = ObjectUtil.toString( filteredInput );
				}
				var varName : String;
				var re : RegExp;

				while( outMessage.match( /\$\w+/ ) )
				{
					varName = outMessage.match( /\$\w+/ )[ 0 ];
					re = new RegExp( "\\\u0024" + varName.substr( 1 ) + "", "g" );
					outMessage = outMessage.replace( re, context.variables[ varName.substr( 1 ) ] );
				}
				var args : Array = [ _levels[ level ], outMessage ];
				args = args.concat( parameters );

				if( LOGGER )
				{
					var logFn : Function  = LOGGER[ "log" ] as Function;

					if( logFn != null )
						logFn.apply( LOGGER, args );
				}
				complete( _inputData );
			}
			catch( e : Error )
			{
				fail( e.message );
			}
		}
	}
}
