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
package org.astoolkit.workflow.task.data
{

	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.filesystem.File;
	import flash.net.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import org.astoolkit.workflow.constant.PIPELINE_OUTLET;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Opens a connection to a SQLite file.
	 * <p>An anonymous variable of type SQLConnection is set upon completion</p>
	 * <p>
	 * <b>Any Input</b>
	 * </p>
	 * <p>
	 * <b>Output</b>
	 * <ul>
	 * <li>The created connection</li>
	 * </ul>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>source</code> (Injectable): a File object that represents the .db file</li>
	 * </ul>
	 * </p>
	 */
	public class OpenSQLConnection extends BaseTask
	{

		private var _path : String;

		private var _source : File;

		public var forceCreation : Boolean;

		[Inspectable( enumeration="create,read,update", defaultValue="read" )]
		public var mode : String = SQLMode.READ;

		public var name : String;

		public var openAsync : Boolean;

		[InjectPipeline]
		public function set path( inValue :String) : void
		{
			_onPropertySet( "path" );
			_path = inValue;
		}

		[InjectPipeline]
		public function set source( inValue :File) : void
		{
			_onPropertySet( "source" );
			_source = inValue;
		}

		override public function begin() : void
		{
			super.begin();

			if( !_source && !_path )
			{
				fail( "No database file provided" );
				return;
			}

			try
			{
				var file : File = 
					_source != null ? _source : 
					_path != null ? new File( _path ) : null;

				if( !file )
				{
					fail( "No file/path provided" );
					return;
				}

				if( !forceCreation && !file.exists )
				{
					fail( "Provided file/path doesn't exist. You can forceCreation=\"true\"." );
					return;
				}
				var localMode : String = !file.exists ? "create" : mode;

				var conn : SQLConnection = new SQLConnection();

				if( openAsync )
					conn.openAsync( file, localMode, new Responder( onDBOpenResult, onDBOpenFault ) );
				else
				{
					conn.open( file, localMode );

					var connName : String = name != null ? 
						( name.match( /^\$/ ) ? 
						name : 
						"$" + name ) : 
						"$sqlconnection" + ( new Date() ).time;
					ENV[ connName ] = conn;

					complete( conn );
				}
			}
			catch( err : Error )
			{
				fail( "Error thrown while trying to open db file '{0}'", file.nativePath );
			}

		}

		private function onDBOpenFault( inEvent : FaultEvent ) : void
		{
			fail( inEvent.fault.message );
		}

		private function onDBOpenResult( inEvent : ResultEvent ) : void
		{
			var conn : SQLConnection = inEvent.target as SQLConnection;

			if( outlet == PIPELINE_OUTLET )
				ENV[ "sqlconnection" + ( new Date() ).getTime() ] = conn;
			else
				complete( conn );
		}
	}
}
