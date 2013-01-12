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

	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.ServerSocketConnectEvent;
	import flash.html.HTMLLoader;
	import flash.net.ServerSocket;
	import flash.net.Socket;
	import flash.net.URLRequest;
	import org.astoolkit.workflow.core.BaseTask;

	public class XSLTTransform extends BaseTask
	{

		private var _htmlBridge : HTMLLoader;

		private var _port : int = 1024;

		private var _xml : XML;

		private var _xslt : XML;

		[Inspectable( enumeration="xml,text" )]
		public var outputFormat : String = "xml";

		public var server : ServerSocket;

		[InjectPipeline]
		public function set xml( inValue :XML) : void
		{
			_onPropertySet( "xml" );
			_xml = inValue;
		}

		[InjectPipeline]
		public function set xslt( inValue :XML) : void
		{
			_onPropertySet( "xslt" );
			_xslt = inValue;
		}

		override public function begin() : void
		{
			super.begin()

			if( !_xml && !_xslt )
			{
				fail( "Either or both xml/xslt not set" );
				return;
			}

			if( !_xml )
			{
				if( filteredInput is XML )
					xml = filteredInput as XML;
				else
				{
					fail( "xml not set" );
					return;
				}
			}

			if( !_xslt )
			{
				if( filteredInput is XML )
					xslt = filteredInput as XML;
				else
				{
					fail( "xslt not set" );
					return;
				}
			}

			if( _htmlBridge.loaded )
				xsltTransform();
			else
			{
				_htmlBridge.addEventListener( Event.COMPLETE, onHtmlBridgeComplete );
			}
		}

		override public function cleanUp() : void
		{
			super.cleanUp();

			if( _htmlBridge.loaded && server )
			{
				server.close();
				server = null;
			}
		}

		override public function initialize() : void
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

		private function onClientConnect( inEvent : ServerSocketConnectEvent ) : void
		{
			inEvent.socket.addEventListener( ProgressEvent.SOCKET_DATA, onSockedData );
		}

		private function onHtmlBridgeComplete( inEvent : Event ) : void
		{
			xsltTransform();
		}

		private function onSockedData( inEvent : ProgressEvent ) : void
		{
			var socket : Socket = Socket( inEvent.target );
			socket.writeUTFBytes( "HTTP/1.1 200 OK\n" );
			socket.writeUTFBytes( "Content-Type: text/html\n\n" );
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
				"</html>\n" );
			socket.flush();
			socket.close();
		}

		private function xsltTransform() : void
		{
			try
			{
				var result : String = _htmlBridge.window.transformXML( _xml, _xslt );
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
