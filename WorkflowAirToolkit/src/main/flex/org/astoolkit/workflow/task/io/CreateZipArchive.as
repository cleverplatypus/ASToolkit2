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

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import deng.fzip.FZip;
	import org.astoolkit.workflow.core.BaseTask;

	public class CreateZipArchive extends BaseTask
	{

		private var _baseDir : File;

		private var _currentByteArray : ByteArray;

		private var _currentFileQueue : Array;

		private var _currentInStream : FileStream;

		private var _destinationFile : File;

		private var _sourceFile : File;

		private var _sourceFiles : Vector.<File>;

		private var _zip : FZip;

		[InjectPipeline]
		public function set destinationFile( inValue :File) : void
		{
			_onPropertySet( "destinationFile" );
			_destinationFile = inValue;
		}

		public var readSize : uint = 51200;

		[InjectPipeline]
		public function set sourceFile( inValue:File) : void
		{
			_onPropertySet( "sourceFile" );
			_sourceFile = inValue;
		}

		[InjectPipeline]
		public function set sourceFiles( inValue :Vector.<File>) : void
		{
			_onPropertySet( "sourceFiles" );
			_sourceFiles = inValue;
		}

		public var wrappingDirName : String;

		override public function begin() : void
		{
			super.begin();

			if( !_sourceFile && !_sourceFiles )
			{
				fail( "No source file(s) provided.\nIf providing multiple files " +
					"make sure the list passed is of type Vector.<flash.filesystem.File>" );
				return;
			}

			if( !_destinationFile )
			{
				fail( "No destination archive file provided" );
				return;
			}
			_currentFileQueue = [];
			_zip = new FZip();

			if( _sourceFile )
			{
				_baseDir = _sourceFile.parent;
				_currentFileQueue.push( [ _sourceFile ] )
			}
			else if( _sourceFiles && _sourceFiles.length > 0 )
			{
				_baseDir = _sourceFiles[ 0 ].parent;
				_currentFileQueue.push( _sourceFiles );
			}

			if( _currentFileQueue.length > 0 )
				processQueue();
			else
				complete();
		}

		private function processQueue() : void
		{
			if( _currentFileQueue.length == 0 )
			{
				queueComplete();
				return;
			}
			var files : Array = _currentFileQueue[ _currentFileQueue.length - 1 ];

			if( files.length == 0 )
			{
				_currentFileQueue.pop();
				processQueue();
				return;
			}
			var file : File = files[ files.length - 1 ];

			if( file.isDirectory )
			{
				_currentFileQueue.push( file.getDirectoryListing() );
				files.pop();
				processQueue();
				return;
			}

			if( !_currentInStream )
			{
				_currentInStream = new FileStream();
				_currentInStream.open( file, FileMode.READ );
				_currentByteArray = new ByteArray();
				processQueue();
				return;
			}

			if( _currentInStream.bytesAvailable == 0 )
			{
				var localName : String =
					file.nativePath.replace(
					new RegExp(
					"^" + _baseDir.nativePath.replace( "/", "\\/" ) + "\\/" ),
					wrappingDirName ? wrappingDirName + "/" : "" );
				_zip.addFile( localName, _currentByteArray );
				files.pop();
				_currentInStream = null;
				_currentByteArray = null;
				processQueue();
				return;
			}
			else
			{
				_currentInStream.readBytes( _currentByteArray, _currentInStream.position, Math.min( _currentInStream.bytesAvailable, readSize ) );
				setTimeout( processQueue, 1 );
			}
		}

		private function queueComplete() : void
		{
			var outStream : FileStream = new FileStream();
			outStream.open( _destinationFile, FileMode.WRITE );
			_zip.serialize( outStream );
			_zip.close();
			complete();
		}
	}
}
