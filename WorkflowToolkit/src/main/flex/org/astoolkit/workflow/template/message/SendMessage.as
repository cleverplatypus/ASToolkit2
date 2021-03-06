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
package org.astoolkit.workflow.template.message
{

	import mx.core.IFactory;
	import org.astoolkit.commons.factory.api.IFactoryResolver;
	import org.astoolkit.workflow.core.BaseTaskTemplate;
	import org.astoolkit.workflow.task.api.ISendMessage;

	/**
	 * Template for sending a message through a message bus.
	 * The actual implementation must be provided via a context plug-in.
	 */
	public dynamic class SendMessage extends BaseTaskTemplate implements ISendMessage
	{

		public function set factoryResolver( inValue : IFactoryResolver ) : void
		{
			setImplementationProperty( "factoryResolver", inValue );

		}

		public function set hasAsyncResult( inValue : Boolean ) : void
		{
			setImplementationProperty( "hasAsyncResult", inValue );
		}

		[AutoAssign]
		public function set message( inValue : Object ) : void
		{
			setImplementationProperty( "message", inValue );
		}

		[AutoAssign]
		public function set messageClass( inValue : Class ) : void
		{
			setImplementationProperty( "messageClass", inValue );
		}

		[AutoAssign]
		public function set messageFactory( inValue : IFactory ) : void
		{
			setImplementationProperty( "messageFactory", inValue );
		}

		public function set messageMappingFailurePolicy( inValue : String ) : void
		{
			setImplementationProperty( "messageMappingFailurePolicy", inValue );
		}

		[AutoAssign]
		public function set messagePropertiesMapping( inValue : Object ) : void
		{
			setImplementationProperty( "messagePropertiesMapping", inValue );
		}

		public function set scope( inValue : Object ) : void
		{
			setImplementationProperty( "scope", inValue );
		}

		public function set selector( inValue : * ) : void
		{
			setImplementationProperty( "selector", inValue );
		}
	}
}
