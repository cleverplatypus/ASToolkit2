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
package org.astoolkit.workflow.parsleysupport
{

	import mx.utils.object_proxy;

	import org.spicefactory.lib.reflect.ClassInfo;
	import org.spicefactory.lib.reflect.Method;
	import org.spicefactory.lib.reflect.Parameter;
	import org.spicefactory.parsley.command.MappedCommandBuilder;
	import org.spicefactory.parsley.comobserver.receiver.DefaultCommandObserver;
	import org.spicefactory.parsley.core.command.CommandStatus;
	import org.spicefactory.parsley.core.context.provider.Provider;
	import org.spicefactory.parsley.core.lifecycle.ManagedObject;
	import org.spicefactory.parsley.core.messaging.MessageReceiverKind;
	import org.spicefactory.parsley.core.processor.MethodProcessor;
	import org.spicefactory.parsley.core.processor.PropertyProcessor;
	import org.spicefactory.parsley.core.processor.StatefulProcessor;
	import org.spicefactory.parsley.messaging.receiver.MessageReceiverInfo;

	public class CommandProcessor implements MethodProcessor
	{

		private var _method : Method;

		public function init( inTarget : ManagedObject ) : void
		{
			var meta : CommandDecorator = CommandDecorator( _method.getMetadata( CommandDecorator )[0] );
			var builder:MappedCommandBuilder = 
				MappedCommandBuilder.forFactory( 
				new Factory( inTarget.instance, inTarget.instance[ _method.name ] as Function, inTarget.context ) );

			builder
				.messageType( Parameter( _method.parameters[0] ).type.getClass() )
				.selector( meta.selector )
				.order( meta.order )
				.register( inTarget.context);
		}

		public function destroy(target:ManagedObject) : void
		{
			// TODO Auto-generated method stub
		}

		public function targetMethod( inMethod : Method ) : void
		{
			_method = inMethod;
		}
	}
}
import org.astoolkit.workflow.parsleysupport.ControllerCommand;
import org.spicefactory.lib.command.builder.CommandProxyBuilder;
import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.parsley.command.impl.DefaultManagedCommandProxy;
import org.spicefactory.parsley.core.command.ManagedCommandFactory;
import org.spicefactory.parsley.core.command.ManagedCommandProxy;
import org.spicefactory.parsley.core.context.Context;

class Factory implements ManagedCommandFactory
{
	private var _target : Object;

	private var _method : Function;

	private var _context : Context;

	public function Factory( inTarget : Object, inMethod : Function, inContext  : Context ) : void
	{
		_target = inTarget;
		_method = inMethod;
	}

	public function get type() : ClassInfo
	{
		return ClassInfo.forInstance( _target );
	}

	public function newInstance() : ManagedCommandProxy
	{
		var target : Object = ControllerCommand.create( _target, _method );
		var proxy:DefaultManagedCommandProxy = new DefaultManagedCommandProxy(_context);
		var builder:CommandProxyBuilder = new CommandProxyBuilder(target, proxy);
		builder.build();
		return proxy;

	}
}
