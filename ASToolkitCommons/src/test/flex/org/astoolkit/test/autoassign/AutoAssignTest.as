package org.astoolkit.test.autoassign
{

	import org.astoolkit.lang.util.getClass;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;

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
		[Ignore]
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
			assertStrictlyEquals(
				"classOrFactory === Number",
				Number,
				doc.classOrFactory );
			assertTrue( 
				"genericObject is Object and genericObject.prop == 'success'",
				doc.genericObject &&
				getClass( doc.genericObject ) === Object &&
				doc.genericObject.prop == "success" )
		}
	}
}
