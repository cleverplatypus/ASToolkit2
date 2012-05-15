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
package org.astoolkit.workflow.task.data
{
	import org.astoolkit.workflow.core.BaseTask;
	
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.html.HTMLLoader;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.net.URLRequest;
	
	public class XSLTTransform extends BaseTask
	{
		
		[Bindable][InjectPipeline]
		public var xml : XML;
		
		[Bindable][InjectPipeline]
		public var xslt : XML;
		
		private var _htmlBridge : HTMLLoader;
		
		[Inspectable(enumeration="xml,text")]
		public var outputFormat : String = xml;
		public var server : ServerSocket;
		private var _port : int = 1024;
		
		override public function initialize():void
		{
			super.initialize();
			if( _htmlBridge )
				return;
			server = new ServerSocket();
			while( true )
			{
				try
				{
					server.bind( _port, "127.0.0.1" );
					break;
				}
				catch( e : Error )
				{
					_port++;
				}
			}
			server.listen();
			server.addEventListener( ServerSocketConnectEvent.CONNECT, onClientConnect );
			_htmlBridge = new HTMLLoader();
			_htmlBridge.load( new URLRequest( "http://127.0.0.1:" + _port ) );
		}
		
		override public function cleanUp():void
		{
			super.cleanUp();
			if( _htmlBridge.loaded && server )
			{
				server.close();
				server = null;
			}
		}
		private function onClientConnect( inEvent : ServerSocketConnectEvent ) : void
		{
			inEvent.socket.addEventListener( ProgressEvent.SOCKET_DATA, onSockedData );
		}
		
		private function onSockedData( inEvent : ProgressEvent ) : void
		{
			var socket : Socket = Socket( inEvent.target );
			socket.writeUTFBytes("HTTP/1.1 200 OK\n");
			socket.writeUTFBytes("Content-Type: text/html\n\n");
			socket.writeUTFBytes( "<html>\n" + 
				"<head>\n" +
				"<script type=\"text/javascript\">\n" +
				
				"function transformXML(xml,xsl)\n" +
				"{\n" +
				"var domParser = new DOMParser();\n" +
				"var xmlObject = domParser.parseFromString(xml,\"text/xml\");\n" +
				"var xslObject = domParser.parseFromString(xsl,\"text/xml\");\n" +
				"var xsltProcessor = new XSLTProcessor();\n" +
				"xsltProcessor.importStylesheet(xslObject);\n" +
				"var result = xsltProcessor.transformToFragment(\n" +
				"xmlObject,document);\n" +
				"var serializer = new XMLSerializer();\n" +
				"return serializer.serializeToString(result);\n" +
				"}\n" +
				"</script>\n" +
				"</head>\n" +
				"</html>\n");
			socket.flush();
			socket.close();
		}
		
		override public function begin() : void
		{
			super.begin()
			if( !xml && !xslt )
			{
				fail( "Either or both xml/xslt not set" );
				return;
			}
			if( !xml )
			{
				if( filteredPipelineData is XML )
					xml = filteredPipelineData as XML;
				else
				{
					fail( "xml not set" );
					return;
				}
			}
			if( !xslt )
			{
				if( filteredPipelineData is XML )
					xslt = filteredPipelineData as XML;
				else
				{
					fail( "xslt not set" );
					return;
				}
			}
			if( _htmlBridge.loaded )
				transform();
			else
			{
				_htmlBridge.addEventListener( Event.COMPLETE, onHtmlBridgeComplete );
				
			}
		}
		
		private function onHtmlBridgeComplete( inEvent : Event ) : void
		{
			transform();
		}
		
		private function transform() : void
		{
			try
			{
				var result:String = _htmlBridge.window.transformXML(xml,xslt);
				var out : *;
				if( outputFormat == "xml" )
					out = new XML( result );
				else
					out = result;
				complete( out );
			}
			catch( e : Error )
			{
				fail( "XSLT transformation failed. \nCause:\n" + e.getStackTrace() );
				return;
			}
		}
	}
}