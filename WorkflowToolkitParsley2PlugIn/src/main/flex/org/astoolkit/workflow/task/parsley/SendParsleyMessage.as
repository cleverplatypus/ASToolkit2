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
package org.astoolkit.workflow.task.parsley
{

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.IFactory;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectUtil;
	import mx.utils.StringUtil;
	
	import org.astoolkit.commons.factory.IPooledFactory;
	import org.astoolkit.commons.mapping.MappingError;
	import org.astoolkit.commons.mapping.SimplePropertiesMapper;
	import org.astoolkit.commons.mapping.api.IPropertiesMapper;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.workflow.constant.FailurePolicy;
	import org.astoolkit.workflow.task.api.ISendMessage;
	import org.spicefactory.parsley.core.messaging.command.CommandObserverProcessor;
	import org.spicefactory.parsley.core.messaging.command.CommandStatus;
	import org.spicefactory.parsley.core.messaging.receiver.CommandObserver;

	/**
	 * Sends a message through Parsley's message bus.<br><br>
	 * If isCommand is set to <code>true</code>, the task will
	 * wait for either a command result or a fault to complete.
	 * Otherwise it will complete straight after sending the message.
	 */
	[Bindable]
	public class SendParsleyMessage extends AbstractParsleyTask implements ISendMessage
	{
		private static const LOGGER : ILogger =
			Log.getLogger( getQualifiedClassName( SendParsleyMessage ).replace( /:+/g, "." ) );

		/**
		 * if true this task will add a responder to the message's destination
		 * and will wait for a result or a fault event to be dispatched
		 * before completing.<br><br>
		 *
		 * In Parsley terms, we use <code>isCommand="true"</code>
		 * to invoke a <code>[Command]</code> tagged function returning an AsyncToken.
		 * Otherwise, for a <code>[MessageHandler]</code> tagged function we set
		 *  <code>isCommand="false"</code>.
		 */
		public var hasAsyncResult : Boolean = false;

		/**
		 * the message instance to be sent. Ignored if <code>messageFactory</code> is set.
		 *
		 * @see messageFactory
		 */
		public var message : Object;

		/**
		 * a factory to create messages. If set, the <code>message</code> property is ignored.
		 *
		 * <p>If both this property and <code>message</code> are omitted, the task will check
		 * the task input for either <code>IFactory</code> instances or other types of object
		 * that will be use as message .</p>
		 */
		public var messageFactory : IFactory;

		public var messageClass : Class;
		
		[Inspectable( enumeration="abort,ignore,log-error,log-warn,log-info,log-debug", defaultValue="abort" )]
		public var messageMappingFailurePolicy : String = FailurePolicy.ABORT;

		/**
		 * the message handler selector value
		 */
		public var selector : *;

		private var _completeObserver : CommandObserver;

		private var _errorObserver : CommandObserver;

		private var _mapper : IPropertiesMapper;

		private var _mappingInfo : Object;

		private var _processor : CommandObserverProcessor;

		
		override public function begin() : void
		{
			super.begin();

			var aFactory : IFactory = messageClass != null ? context.getPooledFactory( messageClass ) : messageFactory;

			var aMessage : Object = aFactory != null ? aFactory.newInstance() : message;
			
			var pData : Object = filteredInput;

			if( !aMessage )
			{
				aMessage = pData;
			}
			else
			{
				if( aMessage is IFactory )
				{
					aMessage = IFactory( aMessage ).newInstance();
				}

				if( mapper )
				{
					try
					{
						mapper.strict = messageMappingFailurePolicy == FailurePolicy.ABORT;
						mapper.mapFailDelegate = function( inProperty : String ) : void
						{
							if( messageMappingFailurePolicy.match( /^log\-/ ) )
								LOGGER[ messageMappingFailurePolicy.replace( /^log\-/, "" ) ](
									getMappingErrorMessage( aMessage, pData, inProperty )
									);
						};
						
						mapper.mapWith( pData, _mappingInfo, aMessage );
					}
					catch( e : MappingError )
					{
						if( messageMappingFailurePolicy == FailurePolicy.ABORT )
						{
							fail( e.message );
							return;
						}
					}
				}
			}

			if( hasAsyncResult )
			{
				var clazz : Class = getDefinitionByName( getQualifiedClassName( aMessage ) ) as Class;
				_completeObserver = createThreadSafeObserver(
					CommandStatus.COMPLETE,
					selector,
					clazz,
					1,
					onObserverCommandComplete );
				_errorObserver = createThreadSafeObserver(
					CommandStatus.ERROR,
					selector,
					clazz,
					1,
					onObserverCommandFault );
				registerCommandObserver( _completeObserver );
				registerCommandObserver( _errorObserver );
			}
			parsleyContext.scopeManager.getScope( scope as String ).dispatchMessage( aMessage, selector );
			if( aFactory is IPooledFactory )
				IPooledFactory( aFactory ).release( aMessage );
			if( !hasAsyncResult )
				complete();
		}

		override public function cleanUp() : void
		{
			super.cleanUp();

			if( hasAsyncResult )
			{
				if( _completeObserver )
					unregisterCommandObserver( _completeObserver );
				if( _errorObserver )
					registerCommandObserver( _errorObserver );
				_completeObserver = null;
				_errorObserver = null;
			}
		}

		/**
		 * an optional object which name-value pairs represents the
		 * mapping between the properties in the pipeline data object
		 * and the message to be sent where name is the message's property name
		 * and value is the pipeline data object property name to be copied.
		 * <br><br>
		 *
		 * <br><br>
		 * @example Mapping message properties from pipeline data<br>
		 * <listing>
		 * &lt;SendMessage
		 * 		messagePropertiesMapping="{ { itemId : 'id', price : 'priceWithVAT' } }"
		 * 		message="{ new ClassFactory( SendItemPriceMessage ) }"
		 * 		/&gt;
		 * </listing>
		 *
		 * If inputFilter is set, mapping is performed on the filtered data.
		 */
		public function set messagePropertiesMapping( inValue : Object ) : void
		{
			if( inValue is IPropertiesMapper )
				_mapper = inValue as IPropertiesMapper;
			else
				_mappingInfo = inValue;
		}

		override public function prepare() : void
		{
			super.prepare();
		}

		override protected function complete( inOutputData : * = null ) : void
		{
			super.complete( inOutputData );
		}

		protected function get mapper() : IPropertiesMapper
		{
			if( !_mapper && _mappingInfo )
			{
				_mapper = ENV.mapTo.object( null, _mappingInfo );
			}
			return _mapper;
		}

		private function getMappingErrorMessage( inSource : Object, inTarget : Object, inProperty : String ) : String
		{
			return StringUtil.substitute(
				"Failed mapping property '{0}' from {1} to {2}",
				inProperty,
				getQualifiedClassName( inSource ),
				getQualifiedClassName( inTarget ) );
		}

		private function onObserverCommandComplete( inData : Object, inMessage : Object ) : void
		{
			complete( inData );
		}

		private function onObserverCommandFault( inErrorMessage : String, inMessage : Object ) : void
		{
			fail( inErrorMessage );
		}
	}
}
