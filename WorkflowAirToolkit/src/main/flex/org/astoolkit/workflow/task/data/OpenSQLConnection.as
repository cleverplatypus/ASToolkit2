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

		[Bindable]
		[InjectPipeline]
		public var source : File;

		override public function begin() : void
		{
			super.begin();
			var conn : SQLConnection = new SQLConnection();

			if( openAsync )
				conn.openAsync( source, mode, new Responder( onDBOpenResult, onDBOpenFault ) );
			else
			{
				conn.open( source, mode );

				if( outlet == PIPELINE_OUTLET )
				{
					ENV[ "$sqlconnection" + ( new Date() ).getTime() ] = conn;
					complete();
				}
				else
					complete( conn );
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
