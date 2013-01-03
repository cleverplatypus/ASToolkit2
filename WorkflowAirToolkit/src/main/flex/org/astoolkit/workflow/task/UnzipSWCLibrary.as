package org.astoolkit.workflow.task
{

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import mx.rpc.Responder;
	import org.astoolkit.commons.utils.SWCLibraryExtractor;
	import org.astoolkit.workflow.core.BaseTask;

	[TaskInput( "flash.filesystem.File" )]
	public class UnzipSWCLibrary extends BaseTask
	{

		[Bindable]
		[InjectPipeline]
		public var swcFile : File;

		private var _extractor : SWCLibraryExtractor;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();
			_extractor = new SWCLibraryExtractor( swcFile );
			_extractor.extractSWFLibrary( new Responder( onExtractorSuccess, onExtractorFault ) );
		}

		[Inspectable( enumeration="bytearray,tempfile" )]
		override public function set outputKind( inValue : String ) : void
		{
			super.outputKind = inValue;
		}

		private function onExtractorFault( inErr : Error ) : void
		{
			fail( "SWF extraction failed.\n{0}", inErr.getStackTrace() );
		}

		private function onExtractorSuccess( inData : ByteArray ) : void
		{
			if( _outputKind == "bytearray" )
				complete( inData );
			else
			{
				var file : File = File.createTempFile();
				var stream : FileStream = new FileStream();
				stream.endian = Endian.LITTLE_ENDIAN;
				stream.open( file, FileMode.WRITE );
				stream.writeBytes( inData, 0, inData.bytesAvailable );
				stream.close();
				complete( file );
			}
		}
	}
}