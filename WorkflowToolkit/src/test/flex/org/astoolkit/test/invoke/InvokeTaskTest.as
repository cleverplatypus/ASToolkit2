package org.astoolkit.test.invoke
{

	import org.astoolkit.test.invoke.workflow.InvokeTaskWorkflow;
	import org.astoolkit.workflow.core.ExitStatus;
	import org.astoolkit.workflow.core.WorkflowEvent;
	import org.astoolkit.workflow.plugin.audit.AuditData;
	import org.astoolkit.workflow.plugin.audit.AuditPlugIn;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	public class InvokeTaskTest
	{
		private static var _workflow : InvokeTaskWorkflow;

		[Before]
		public function setUp() : void
		{
		}

		[After]
		public function tearDown() : void
		{
		}

		[BeforeClass]
		public static function setUpBeforeClass() : void
		{
			_workflow = new InvokeTaskWorkflow();
		}

		[AfterClass]
		public static function tearDownAfterClass() : void
		{
		}

		[Test( async, description="Testing simpleInvoke task" )]
		public function simpleInvoke() : void
		{
			var f : Function = Async.asyncHandler( this, onSimpleInvokeComplete, 1000 );
			_workflow.addEventListener( WorkflowEvent.COMPLETED, f );
			_workflow.enableOnly( _workflow.simpleInvoke );
			_workflow.run();
		}

		private function onSimpleInvokeComplete( inEvent : WorkflowEvent, inPassThroughData : Object ) : void
		{
			var auditData : AuditData =
				_workflow.context.getPluginData( AuditPlugIn ) as AuditData;
			assertTrue(
				"simpleInvoke output == true",
				auditData.getOuputData( "simpleInvoke" )[ 0 ] );
		}

		[Test( async, description="Testing squareRootInvoke task with parameter" )]
		public function squareRootInvoke() : void
		{
			var f : Function = Async.asyncHandler( this, onSquareRootInvokeComplete, 1000 );
			_workflow.addEventListener( WorkflowEvent.COMPLETED, f );
			_workflow.enableOnly( _workflow.squareRootInvoke );
			_workflow.run();
		}

		private function onSquareRootInvokeComplete( inEvent : WorkflowEvent, inPassThroughData : Object ) : void
		{
			var auditData : AuditData =
				_workflow.context.getPluginData( AuditPlugIn ) as AuditData;
			assertEquals(
				"squareRootInvoke output == 9",
				9,
				auditData.getOuputData( "squareRootInvoke" )[ 0 ] );
		}

		[Test( async, description="Testing squareRootInvoke task with parameter and method builder" )]
		public function squareRootMethodBuilderInvoke() : void
		{
			var f : Function = Async.asyncHandler( this, onSquareRootInvokeMethodBuilderComplete, 1000 );
			_workflow.addEventListener( WorkflowEvent.COMPLETED, f );
			_workflow.enableOnly( _workflow.squareRootMethodBuilderInvoke );
			_workflow.run();
		}

		private function onSquareRootInvokeMethodBuilderComplete( inEvent : WorkflowEvent, inPassThroughData : Object ) : void
		{
			var auditData : AuditData =
				_workflow.context.getPluginData( AuditPlugIn ) as AuditData;
			assertEquals(
				"squareRootMethodBuilderInvoke output == 12",
				12,
				auditData.getOuputData( "squareRootMethodBuilderInvoke" )[ 0 ] );
		}

		[Test( async, description="Testing stringToUppercaseAsync task with parameter" )]
		public function stringToUppercaseAsync() : void
		{
			var f : Function = Async.asyncHandler( this, onStringToUppercaseAsyncComplete, 10000 );
			_workflow.addEventListener( WorkflowEvent.COMPLETED, f );
			_workflow.enableOnly( _workflow.stringToUppercaseAsyncInvoke );
			_workflow.run();
		}

		private function onStringToUppercaseAsyncComplete( inEvent : WorkflowEvent, inPassThroughData : Object ) : void
		{
			var auditData : AuditData =
				_workflow.context.getPluginData( AuditPlugIn ) as AuditData;
			assertEquals(
				"stringToUppercaseAsyncInvoke output == 'I AM ASYNC'",
				"I AM ASYNC",
				auditData.getOuputData( "stringToUppercaseAsyncInvoke" )[ 0 ] );
		}

		[Test( async, description="Testing ExitStatus for Invoke with undefined method" )]
		public function undefinedMethodTest() : void
		{
			var f : Function = Async.asyncHandler( this, onUndefinedMethodTestComplete, 1000 );
			_workflow.addEventListener( WorkflowEvent.COMPLETED, f );
			_workflow.enableOnly( _workflow.undefinedMethodInvoke );
			_workflow.run();
		}

		private function onUndefinedMethodTestComplete( inEvent : WorkflowEvent, inPassThroughData : Object ) : void
		{
			var auditData : AuditData =
				_workflow.context.getPluginData( AuditPlugIn ) as AuditData;
			assertEquals(
				"undefinedMethodInvoke exitStatus == 'failed'",
				ExitStatus.FAILED,
				auditData.getExitStatus( "undefinedMethodInvoke" )[ 0 ].code );
		}

	}
}
