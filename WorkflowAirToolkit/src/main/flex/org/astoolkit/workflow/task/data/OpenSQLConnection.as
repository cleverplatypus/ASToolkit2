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
	
	public class OpenSQLConnection extends BaseTask
	{
		public var openAsync : Boolean;

		[Bindable][InjectPipeline]
		public var source : File;
		
		[Inspectable( enumeration="create,read,update", defaultValue="read")]
		public var mode : String = SQLMode.READ;
		
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
					$[ "sqlconnection" + ( new Date() ).getTime() ] = conn;
					complete();
				}
				else
					complete( conn );
			}
				
		}
		
		private function onDBOpenResult( inEvent : ResultEvent ) : void
		{
			var conn : SQLConnection = inEvent.target as SQLConnection;
			if( outlet == PIPELINE_OUTLET )
				$[ "sqlconnection" + ( new Date() ).getTime() ] = conn;
			else
				complete( conn );
		}
		
		private function onDBOpenFault( inEvent : FaultEvent ) : void
		{
			fail( inEvent.fault.message );
		}
		
	}
}