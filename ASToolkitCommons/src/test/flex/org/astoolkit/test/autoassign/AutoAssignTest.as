package org.astoolkit.test.autoassign
{

	import org.flexunit.asserts.assertEquals;

	public class AutoAssignTest
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
		public function testDocument1() : void
		{
			var doc : Document1 = new Document1();
			doc.build();
			assertEquals( 
				"mappedWithPid property == 'mappedWithPid:success'",
				"mappedWithPid:success",
				doc.mappedWithPid );
			assertEquals( 
				"builtString property == 'builtString:success'",
				"builtString:success",
				doc.builtString );
			assertEquals( 
				"secondaryString property == 'secondaryString:success'",
				"secondaryString:success",
				doc.secondaryString );
		}
	}
}
