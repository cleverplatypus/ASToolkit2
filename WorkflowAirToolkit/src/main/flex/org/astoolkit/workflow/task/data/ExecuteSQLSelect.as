package org.astoolkit.workflow.task.data
{
	
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.net.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import org.astoolkit.workflow.core.BaseTask;
	
	public class ExecuteSQLSelect extends BaseTask
	{
		
		[InjectVariable]
		public var connection : SQLConnection;
		
		public var itemClass : Class;
		
		[Bindable]
		[InjectPipeline]
		public var sql : String;
		
		override public function begin() : void
		{
			super.begin();
			
			if(!connection)
			{
				var tmp : * = $.byType( SQLConnection );
				
				if(tmp)
					connection = tmp as SQLConnection;
				else
					fail( "No connection provided" );
			}
			var statement : SQLStatement = new SQLStatement();
			statement.sqlConnection = connection;
			statement.text = sql;
			statement.itemClass = itemClass;
			statement.execute( -1, new Responder( onStatementResult, onStatementFault ));
		}
		
		private function onStatementFault( inEvent : SQLError ) : void
		{
			fail( inEvent.message );
		}
		
		private function onStatementResult( inResult : SQLResult ) : void
		{
			complete( inResult.data );
		}
	}
}
