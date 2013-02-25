package org.astoolkit.test.varlist.workflow
{

	import org.flexunit.asserts.assertEquals;

	public class VarListTest
	{

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
		}

		[AfterClass]
		public static function tearDownAfterClass() : void
		{
		}

		[Test]
		public function variableListTest() : void
		{
			var workflow : VarListWorkflow = new VarListWorkflow();
			var result : String = workflow.run( "GREAT" );
			assertEquals(
				"Workflow output == 'MYGREATLISTTEST'",
				"MYGREATLISTTEST",
				result );

		}

	}
}
