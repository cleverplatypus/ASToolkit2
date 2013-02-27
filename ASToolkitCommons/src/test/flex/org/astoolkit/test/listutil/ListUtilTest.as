package org.astoolkit.test.listutil
{

	import mx.collections.ArrayCollection;

	import org.astoolkit.commons.utils.ListUtil;
	import org.astoolkit.commons.utils.getClass;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertTrue;

	public class ListUtilTest
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
		public function vectorToArrayCollection() : void
		{
			var result : Object =
				ListUtil.convert( Vector.<String>( [ "a", "b", "c" ] ), ArrayCollection );
			assertTrue(
				"Output is an ArrayCollection",
				result is ArrayCollection );
			assertTrue(
				"Output ArrayCollection length is 3",
				ArrayCollection( result ).length == 3 );
			assertEquals(
				"Output ArrayCollection joined == 'abc'",
				ArrayCollection( result ).toArray().join( "" ), "abc" );

		}

		[Test]
		public function arrayCollectionToVector() : void
		{
			var result : Object =
				ListUtil.convert( new ArrayCollection( [ "v", "e", "c", "t", "o", "r" ] ), getClass( Vector.<String> ) );
			assertTrue(
				"Output is a Vector.<String>",
				result is Vector.<String> );
			assertTrue(
				"Output ArrayCollection length is 3",
				Vector.<String>( result ).length == 6 );
			assertEquals(
				"Output ArrayCollection joined == 'vector'",
				Vector.<String>( result ).join( "" ), "vector" );

		}


	}
}
