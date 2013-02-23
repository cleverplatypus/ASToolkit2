package org.astoolkit.workflow.test
{

	import org.astoolkit.workflow.core.WorkflowEvent;
	import org.astoolkit.workflow.plugin.audit.AuditData;
	import org.astoolkit.workflow.plugin.audit.AuditPlugIn;
	import org.astoolkit.workflow.test.task.XPathContactsTransformTestWorkflow;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;
	import org.flexunit.async.Async;

	public class XPathTransformTest
	{
		private static const _contactsInput : XML =
			<contacts>
				<contact type="person" name="Victor Lehman"/>
				<contact type="company" name="Adobe Inc."/>
				<contact type="person" name="Sarah Michelle Gellar"/>
				<contact type="company" name="Krusty Burgers"/>
			</contacts>;

		private static var _contactsTestWf : XPathContactsTransformTestWorkflow;

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
			_contactsTestWf = new XPathContactsTransformTestWorkflow();
		}

		[AfterClass]
		public static function tearDownAfterClass() : void
		{
		}

		[Test( async, description = "XPath contacts xml test" )]
		public function basicTest() : void
		{
			var f : Function = Async.asyncHandler( this, onWorkflowComplete, 1000 );
			_contactsTestWf.addEventListener( WorkflowEvent.COMPLETED, f );
			_contactsTestWf.addEventListener( WorkflowEvent.FAULT, f );
			_contactsTestWf.run( _contactsInput );
		}

		private function onWorkflowComplete( inEvent : WorkflowEvent, inPassThroughData : Object ) : void
		{
			if( inEvent.type == WorkflowEvent.FAULT )
				assertTrue( "Workflow didn't fail", false );
			var auditData : AuditData =
				_contactsTestWf.context.getPluginData( AuditPlugIn ) as AuditData;
			var peopleNames : Array = auditData.getOuputData( "personTransform" );
			assertEquals(
				"Person contact[0] name is 'Victor Lehman'",
				peopleNames[ 0 ], "Victor Lehman" );
			assertEquals(
				"Person contact[1] name is 'Sarah Michele Gellar'",
				peopleNames[ 1 ], "Sarah Michelle Gellar" );

			var companiesNames : Array = auditData.getOuputData( "companyTransform" );
			assertEquals(
				"Company contact[0] name is 'Adobe Inc.'",
				companiesNames[ 0 ], "Adobe Inc." );
			assertEquals(
				"Person contact[1] name is 'Krusty Burgers'",
				companiesNames[ 1 ], "Krusty Burgers" );
		}


	}
}
