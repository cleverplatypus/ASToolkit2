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
package org.astoolkit.workflow.task.net
{
	import org.astoolkit.workflow.core.BaseTask;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import flashx.textLayout.debug.assert;
	
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.utils.ObjectUtil;
	
	public class UploadFile extends BaseTask
	{
		
		public var url : String;
		public var localFile : FileReference;
		public var params : Object;
	
		override public function begin() : void
		{
			super.begin();
			if( !localFile && filteredPipelineData is FileReference )
				localFile = filteredPipelineData as FileReference;
			if( !localFile )
				fail( "No localFile provided" );
			if( !url )
				fail( "No url provided" );
			localFile.addEventListener( Event.COMPLETE, onUploadComplete );
			localFile.addEventListener( ProgressEvent.PROGRESS, onUploadProgress );
			localFile.addEventListener( HTTPStatusEvent.HTTP_STATUS, onUploadFault );
			localFile.addEventListener( IOErrorEvent.IO_ERROR, onUploadFault );
			var req : URLRequest = new URLRequest( url );
			req.method = URLRequestMethod.POST;
			if( params )
			{
				var vars : URLVariables = new URLVariables();
				for( var k : String in params )
					vars[ k ] = params[k];
				req.data = vars;
			}
			trace( ObjectUtil.toString( req ) );
			localFile.upload( req, "file" );
		}
		
		private function onUploadFault( inEvent : Event ) : void
		{
			if( inEvent is HTTPStatusEvent )
				fail( "Upload failed with HTTP code: " + HTTPStatusEvent( inEvent ).status );
			else if( inEvent is IOErrorEvent )
				fail( "Upload failed with error: " + IOErrorEvent( inEvent ).text );
		}
		
		private function onUploadProgress( inEvent : ProgressEvent ) : void
		{
			setProgress( inEvent.bytesLoaded / inEvent.bytesTotal );
		}
		
		private function onUploadComplete( inEvent : Event ) : void
		{
			complete();
		}
		
		override public function cleanUp():void
		{
			super.cleanUp();
			if( localFile )
			{
				localFile.removeEventListener( Event.COMPLETE, onUploadComplete );
				localFile.removeEventListener( ProgressEvent.PROGRESS, onUploadProgress );
				localFile.removeEventListener( HTTPStatusEvent.HTTP_STATUS, onUploadFault );
			}			
		}
		
	}
}