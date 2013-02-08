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
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.net.Responder;
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.core.Switch;

	public class ExecuteSQLSelect extends BaseTask
	{

		private var _sql : String;

		[Bindable]
		[InjectVariable]
		public var connection : SQLConnection;

		public var itemClass : Class;

		[InjectPipeline]
		[AutoConfig]
		public function set sql( inValue :String) : void
		{
			_onPropertySet( "sql" );
			_sql = inValue;
		}

		[Inspectable(enumeration="all,first,last", defaultValue="all")]
		public var subsetOutput : String;

		override public function begin() : void
		{
			super.begin();

			if( !connection )
			{
				var tmp : * = ENV.byType( SQLConnection );

				if( tmp )
					connection = tmp as SQLConnection;
				else
				{
					fail( "No connection provided" );
					return;
				}
			}
			var statement : SQLStatement = new SQLStatement();
			statement.sqlConnection = connection;
			statement.text = _sql;
			statement.itemClass = itemClass;
			statement.execute( -1, new Responder( threadSafe( onStatementResult ), threadSafe( onStatementFault ) ) );
		}

		private function onStatementFault( inEvent : SQLError ) : void
		{
			fail( inEvent.message );
		}

		private function onStatementResult( inResult : SQLResult ) : void
		{
			if( inResult.data && inResult.data.length > 0 )
			{
				switch( subsetOutput )
				{
					case "first":
						complete( inResult.data[0] );
						return;
					case "last":
						complete( inResult.data[inResult.data.length -1] );
						return;
				}
			}
			complete( inResult.data );
		}
	}
}
