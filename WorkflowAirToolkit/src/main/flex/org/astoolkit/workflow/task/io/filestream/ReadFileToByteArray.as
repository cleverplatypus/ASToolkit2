package org.astoolkit.workflow.task.io.filestream
{

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import org.astoolkit.workflow.core.BaseTask;

	public class ReadFileToByteArray extends BaseTask
	{

		[Inspectable( enumeration="big,little", defaultValue="big" )]
		public var endian : String

		[Bindable]
		[InjectPipeline]
		public var file : File;

		[Bindable]
		[InjectPipeline]
		public var uri : String;

		override public function begin() : void
		{
			super.begin();
			var aFile : File;

			if( !file && !uri )
			{
				fail( "No file or uri parameter set" );
				return;
			}

			if( file )
				aFile = file;
			else
				aFile = new File( uri );

			if( !aFile.exists )
			{
				fail( "File with url \"{0}\" does not exist", aFile.url );
				return;
			}
			var fs : FileStream = new FileStream();
			fs.endian = endian == "big" ? Endian.BIG_ENDIAN : Endian.LITTLE_ENDIAN;
			fs.open( aFile, FileMode.READ );
			var out : ByteArray = new ByteArray();
			fs.readBytes( out );
			complete( out );
		}
	}
}
