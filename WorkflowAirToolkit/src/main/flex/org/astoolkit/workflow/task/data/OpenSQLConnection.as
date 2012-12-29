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

		[Inspectable( enumeration="create,read,update", defaultValue="read" )]
		public var mode : String = SQLMode.READ;

		public var openAsync : Boolean;

		public var forceCreation : Boolean;
		
		[Bindable]
		[InjectPipeline]
		public var source : File;

		[Bindable]
		[InjectPipeline]
		public var path : String;
		
		public var name : String;
		
		override public function begin() : void
		{
			super.begin();
			if( !source && !path )
			{
				fail( "No database file provided" );
				return;
			}
			try
			{
				var file : File = 
					source != null ? source : 
						path != null ? new File( path ) : null;
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
