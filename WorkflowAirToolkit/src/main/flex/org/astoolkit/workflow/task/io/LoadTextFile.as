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
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import org.astoolkit.workflow.core.BaseTask;
	
	/**
	 * Loads a text/xml file into memory.
	 *
	 * <p>
	 * <b>Input</b>
	 * <ul>
	 * <li>a String in URL format</li>
	 * <li>a <code>flash.filesystem.File</code> object</li>
	 * </ul>
   * <b>Output</b><br><br>
		   * either a <code>String</code> or a <code>XML</code> object
	 * depending on the value of <code>contentType</code>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>contentType</code>: either "text" or "e4x"</li>
	 * <li><code>url</code> (injectable): the file's URL</li>
	 * <li><code>file</code> (injectable): a <code>flash.filesystem.File</code> object reppresenting the source file</li>
	 * </ul>
	 * </p>
	 */
	public class LoadTextFile extends BaseTask
	{
		
		[Inspectable( enumeration="text,e4x", defaultValue="text" )]
		public var contentType : String = "text";
		
		[Bindable]
		[InjectPipeline]
		public var file : File;
		
		[Bindable]
		public var loadedContent : Object;
		
		[Bindable]
		[InjectPipeline]
		public var url : String;
		
		override public function begin() : void
		{
			super.begin();
			
			if(!url && !file)
			{
				fail( "File or url not provided" );
				return;
			}
			
			if(url && url.match( /^http(s)?:\/\// ) != null)
			{
				var request : URLLoader = new URLLoader();
				request.addEventListener( Event.COMPLETE, threadSafe( onFileDownloaded ));
				request.addEventListener( IOErrorEvent.IO_ERROR, threadSafe( onFileDownloadError ));
				request.addEventListener( ProgressEvent.PROGRESS, threadSafe( onDownloadProgress ));
				request.dataFormat = URLLoaderDataFormat.TEXT;
				request.load( new URLRequest( url ));
				setProgress( 0 );
			}
			else
			{
				if(url)
				{
					file = new File();
					file.url = url;
				}
				
				if(!file.exists)
				{
					fail( "Local file not found: " + file.nativePath );
					return;
				}
				var stream : FileStream = new FileStream();
				stream.open( file, FileMode.READ );
				var fileText : String;
				
				try
				{
					fileText = stream.readUTFBytes( stream.bytesAvailable );
				}
				catch( e : Error )
				{
					fail( "Failed to read local file: " + file.nativePath );
					return;
				}
				textLoaded( fileText );
			}
		}
		
		override public function prepare() : void
		{
			super.prepare();
			loadedContent = null;
		}
		
		private function onDownloadProgress( inEvent : ProgressEvent ) : void
		{
			setProgress( inEvent.bytesLoaded / inEvent.bytesTotal );
		}
		
		private function onFileDownloadError( inEvent : IOErrorEvent ) : void
		{
			fail( "Failed to download remote file" );
		}
		
		private function onFileDownloaded( inEvent : Event ) : void
		{
			var loader : URLLoader = URLLoader( inEvent.target );
			textLoaded( loader.data != null ? loader.data as String : "" );
		}
		
		private function textLoaded( inText : String ) : void
		{
			if(contentType == "text")
			{
				loadedContent = inText;
			}
			else
			{
				try
				{
					loadedContent = new XML( inText );
				}
				catch( e : Error )
				{
					fail( "Loaded text is not valid XML" );
					return;
				}
			}
			complete( loadedContent );
		}
	}
}
