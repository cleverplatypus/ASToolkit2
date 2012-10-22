package org.astoolkit.workflow.annotation
{

	import flash.utils.ByteArray;
	import mx.utils.Base64Decoder;
	import org.astoolkit.commons.reflection.Metadata;

	[Metadata( name="TaskDescriptor", target="class" )]
	[MetaArg( name="data", type="String", mandatory="true" )]
	public class TaskDescriptor extends Metadata
	{

		public function TaskDescriptor()
		{
			super();
		}

		public function get descriptor() : XML
		{
			var encoded : String = getString( "data", true );
			var decoder : Base64Decoder = new Base64Decoder();
			decoder.decode( encoded );
			var ba : ByteArray = decoder.flush();
			ba.uncompress();
			return new XML( ba.readUTFBytes( ba.length ) );

		}
	}
}
