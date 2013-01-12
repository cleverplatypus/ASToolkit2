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

		private var _file : File;

		private var _uri : String;

		[Inspectable( enumeration="big,little", defaultValue="big" )]
		public var endian : String

		[InjectPipeline]
		public function set file( inValue :File) : void
		{
			_onPropertySet( "file" );
			_file = inValue;
		}

		[InjectPipeline]
		public function set uri( inValue :String) : void
		{
			_onPropertySet( "uri" );
			_uri = inValue;
		}

		override public function begin() : void
		{
			super.begin();
			var aFile : File;

			if( !_file && !_uri )
			{
				fail( "No _file or _uri parameter set" );
				return;
			}

			if( _file )
				aFile = _file;
			else
				aFile = new File( _uri );

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
