package org.astoolkit.test.basic
{

	import org.astoolkit.workflow.api.IWorkflow;
	import org.astoolkit.workflow.core.WorkflowEvent;
	import org.astoolkit.workflow.plugin.audit.AuditData;
	import org.astoolkit.workflow.plugin.audit.AuditPlugIn;
	import org.astoolkit.test.basic.task.BasicWorkflow;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	public class BasicWorkflowTest
	{
		private static var _workflow : BasicWorkflow;

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
			_workflow = new BasicWorkflow();
		}

		[AfterClass]
		public static function tearDownAfterClass() : void
		{
		}

		[Test( async, description = "SetPipeline basic test" )]
		public function basicTest() : void
		{
			var f : Function = Async.asyncHandler( this, onWorkflowComplete, 1000 );
			_workflow.addEventListener( WorkflowEvent.COMPLETED, f );
			_workflow.run();
		}

		private function onWorkflowComplete( inEvent : WorkflowEvent, inPassThroughData : Object ) : void
		{
			var auditData : AuditData =
				_workflow.context.getPluginData( AuditPlugIn ) as AuditData;
			assertTrue( "setPipeline output == 'my output'", auditData.getOuputData( "setPipeline" ) );
			assertTrue( "Workflow output = 'my output'", inEvent.data == 'my output' );
		}


	}
}
