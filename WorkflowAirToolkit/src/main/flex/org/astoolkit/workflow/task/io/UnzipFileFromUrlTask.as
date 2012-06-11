/*

Copyright 2009 Nicola Dal Pont

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Version 2.x

*/
package org.astoolkit.workflow.task.io
{

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import deng.fzip.FZip;
	import deng.fzip.FZipErrorEvent;
	import deng.fzip.FZipEvent;
	import deng.fzip.FZipFile;
	import org.astoolkit.workflow.core.BaseTask;
	import org.astoolkit.workflow.core.BaseTask;

	public class UnzipFileFromUrlTask extends BaseTask
	{
		public var destinationUrl : String;

		public var sourceUrl : String;

		private var destinationFile : File;

		override public function begin() : void
		{
			super.begin();
			destinationFile = new File();
			destinationFile.url = destinationUrl;

			if( destinationFile.isDirectory )
				destinationFile.deleteDirectory( true );
			var zip : FZip = new FZip();
			zip.addEventListener( IOErrorEvent.IO_ERROR, onError );
			zip.addEventListener( FZipErrorEvent.PARSE_ERROR, onError );
			zip.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
			zip.addEventListener( FZipEvent.FILE_LOADED, onZFileLoaded );
			zip.addEventListener( Event.COMPLETE, onDownloadComplete );
			zip.addEventListener( ProgressEvent.PROGRESS, onDownloadProgress );
			zip.load( new URLRequest( sourceUrl ) );
			setProgress( 0 );
		}

		override public function prepare() : void
		{
			super.prepare();
			destinationFile = null;

			if( sourceUrl == null )
				sourceUrl = filteredInput as String;

			if( sourceUrl == null )
				fail( "Invalid source URL" );
		}

		private function cleanCache() : void
		{
			var file : File = destinationFile;

			if( file.exists && file.isDirectory )
				file.deleteDirectory( true );
		}

		private function createRequiredDirectories( fileDirectory : String ) : void
		{
			var directoryArray : Array = fileDirectory.split( "/" );
			var workingDirectory : File = destinationFile;
			var iLength : uint = directoryArray.length - 1;

			for( var i : uint = 0; i < iLength; i++ )
			{
				var directoryName : String = directoryArray[ i ];
				var nextWorkingDirectory : File = workingDirectory.resolvePath( directoryName );

				if( nextWorkingDirectory.exists )
				{
					if( !nextWorkingDirectory.isDirectory )
					{
						throw new Error( nextWorkingDirectory.nativePath + " is not a directory" )
					}
				}
				else
				{
					var newDir : File = File.createTempDirectory();
					var nextWorkingDirectoryProxy : File = newDir.resolvePath( directoryName );
					nextWorkingDirectoryProxy.createDirectory();
					nextWorkingDirectoryProxy.copyTo( nextWorkingDirectory );
				}
				workingDirectory = nextWorkingDirectory;
			}
		}

		private function onDownloadComplete( inEvent : Event ) : void
		{
			complete( destinationFile );
		}

		private function onDownloadProgress( inEvent : ProgressEvent ) : void
		{
			setProgress( inEvent.bytesLoaded / inEvent.bytesTotal );
		}

		private function onError( inEvent : Event ) : void
		{
			fail( "Error downloading or unzipping file" );
		}

		private function onZFileLoaded( inEvent : FZipEvent ) : void
		{
			try
			{
				var tFile : FZipFile = inEvent.file;
				var stream : FileStream = new FileStream();
				createRequiredDirectories( tFile.filename );
				var fileToWrite : File = destinationFile.resolvePath( tFile.filename );

				if( fileToWrite.isDirectory )
				{
					return;
				}
				// open and write to the file stream
				stream.open( fileToWrite, FileMode.WRITE );
				var contentByteArray : ByteArray = tFile.content;
				stream.writeBytes( contentByteArray );
				stream.close();
			}
			catch( error : Error )
			{
				cleanCache();
				fail( error.message );
			}
		}
	}
}
