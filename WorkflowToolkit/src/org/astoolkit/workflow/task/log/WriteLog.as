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
	import org.astoolkit.workflow.core.BaseTask;
	
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.logging.LogEventLevel;
	import mx.utils.ObjectUtil;

	/**
	 * Writes to the currently registered Logger instances.<br><br>
	 * 
	 * <b>Input</b>
	 * <ul>
	 * <li>a value to be logged. If a non-String is passed, 
	 * <code>ObjectUtil.toString( value )</code> is used</li>
	 * </ul>
	 * <b>No Output</b>
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
			Log.getLogger( getQualifiedClassName( WriteLog ).replace(/:+/g, "." ) );
		
		[Bindable][InjectPipeline]
		public var message : String = null;
		public var parameters : Array = [];
		
		[Inspectable(defaultValue="debug", enumeration="debug,info,warn,error,fatal")]
		public var level : String = "debug";
		
		private var _levels : Object =
			{
				debug : LogEventLevel.DEBUG,
				info : LogEventLevel.INFO,
				warn : LogEventLevel.WARN,
				error : LogEventLevel.ERROR,
				fatal : LogEventLevel.FATAL
			};
		
		override public function begin() : void
		{
			super.begin();
			try 
			{
				var outMessage : String = message;
				if( !outMessage )
				{
					
					outMessage = ObjectUtil.toString( filteredPipelineData );
				}
				var varName : String;
				var re : RegExp;
				while( outMessage.match( /\$\w+/ ) )
				{
					varName = outMessage.match( /\$\w+/ )[0];
					re = new RegExp( "\\\u0024" + varName.substr(1) + "", "g" );
					outMessage = outMessage.replace( re, context.variables[ varName.substr(1) ] );
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