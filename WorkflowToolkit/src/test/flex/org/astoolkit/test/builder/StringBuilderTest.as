package org.astoolkit.test.builder
{

	import org.astoolkit.test.builder.workflow.StringBuilderWorkflow;
	import org.astoolkit.workflow.core.WorkflowEvent;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.async.Async;

	public class StringBuilderTest
	{
		private static var _workflow : StringBuilderWorkflow;

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
			_workflow = new StringBuilderWorkflow();
		}

		[AfterClass]
		public static function tearDownAfterClass() : void
		{
		}

		[Test( async, description="Testing async stringBuilder" )]
		public function asyncStringBuilderTest() : void
		{
			var f : Function = Async.asyncHandler( this, onAsyncStringBuilderTestComplete, 1000 );
			_workflow.addEventListener( WorkflowEvent.COMPLETED, f );
			_workflow.run( "Hello" );
		}

		private function onAsyncStringBuilderTestComplete( inEvent : WorkflowEvent, inPassThroughData : Object ) : void
		{
			assertEquals(
				"StringBuilderWorkflow ouput == 'Hello world'",
				"Hello world",
				inEvent.data );
		}

	}
}
