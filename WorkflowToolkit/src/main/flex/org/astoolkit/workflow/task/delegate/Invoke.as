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
package org.astoolkit.workflow.task.delegate
{

	import flash.utils.getQualifiedClassName;
	import mx.core.IFactory;
	import mx.rpc.AsyncToken;
	import mx.rpc.Responder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.StringUtil;
	import org.astoolkit.commons.factory.api.IFactoryResolver;
	import org.astoolkit.commons.factory.api.IFactoryResolverClient;
	import org.astoolkit.commons.io.data.MethodBuilder;
	import org.astoolkit.commons.mapping.api.IPropertiesMapper;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Calls <code>method</code> on the specified target.
	 * The target object can be specified as:
	 * <ul>
	 * <li>an instance: <code>target</code> property</li>
	 * <li>an explicit factory: <code>factory</code> property</li>
	 * <li>a class: <code>type</code> property</code>
	 * </ul>
	 *
	 * <p>
	 * When setting <code>type</code>, the actual instance will be resolved
	 * by the framework using the context's factory resolver.
	 * Check <code>IWorkflowContext.classFactoryMappings</code> documentation for details.
	 * </p>
	 * <p>
	 * Arguments can be passed between brackets in the <code>method</code> parameter, e.g.
	 * <code>method="execute( ., $myVar )"</code>. See <code>method</code> for details.
	 * </p>
	 * <p>
	 * If the method call returns an <code>AsyncToken</code> the task will complete/fail asyncronously
	 * returning the <code>ResultEvent.result</code> value to the pipeline on success.
	 * Any other return type will cause the task to complete synchronously and its return value will be
	 * pushed into the pipeline.
	 * </p>
	 * <p>
	 * <b>Any Input</b>
	 * </p>
	 *
	 * <p>
	 * <b>Any Output</b>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>method</code> (injectable): the method name plus optional parameters</li>
	 * <li><code>liveArguments</code> an optional array of explicit/bond parameters that can be mapped in method params using the :<i>n</i> syntax </li>
	 * <li><code>target</code>: an instance to apply <code>method</code> to</li>
	 * <li><code>factory</code>: a factory for instanciating the target</li>
	 * <li><code>type</code>: a class to be instanciated using the context factory resolver</li>
	 * </ul>
	 * </p>
	 */
	public class Invoke extends BaseTask implements IFactoryResolverClient
	{
		private var _factoryResolver:IFactoryResolver;

		private var _methodBuilder : MethodBuilder;

		private var _usedFactory : IFactory;

		public function set factoryResolver( inValue : IFactoryResolver ) : void
		{
			_factoryResolver = inValue;
		}

		public var liveArguments : Array;

		public var method : String;

		[AutoConfig]
		public function set methodBuilder( inValue : MethodBuilder ) : void
		{
			_methodBuilder = inValue;
		}

		[AutoConfig]
		public var target : Object;

		[AutoConfig]
		public var targetFactory : IFactory

		public var targetType : Class;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			//TODO: use IExpressionResolver for method
			super.begin();
			var localTarget : Object;

			if( _usedFactory )
			{
				localTarget = _usedFactory.newInstance();
			}
			else if( target )
			{
				localTarget = target;
			}
			var builder : MethodBuilder;
			var methodName : String;

			if( method && method.length > 0 )
			{
				if( _methodBuilder )
				{
					fail( "Conflict: method and methodBuilder both defined" );
					return;
				}
				builder = MethodBuilder.parse( method );
				builder.initialized( _document, null );
				_context.configureObjects( [ builder ] );
				methodName = method.match( /^(\w+)/g )[1];
			}
			else if( _methodBuilder )
			{
				builder = _methodBuilder;
				methodName = _methodBuilder.name;
			}
			else
			{
				fail( "No method or methodBuilder defined" );
				return;
			}

			try
			{
				builder.target = localTarget;
				var result : * = ( builder.getData() as Function )();

				if( result is AsyncToken )
				{
					AsyncToken( result ).addResponder( 
						new Responder( threadSafe( onResult ), threadSafe( onFault ) ) );
				}
				else
					complete( result );
			}
			catch( e : Error )
			{
				fail( "Error calling method \"{0}\" on target \"{1}\"\nRoot cause:\n{2} ", 
					methodName, 
					getQualifiedClassName( localTarget ), 
					e.getStackTrace() );
			}
		}

		/**
		 * @private
		 */
		override public function prepare() : void
		{
			super.prepare();
			_usedFactory = null;

			if( targetType && !targetFactory )
			{
				_usedFactory = _factoryResolver.getFactoryForType( targetType );
			}
			else if( targetFactory )
			{
				_usedFactory = targetFactory;
			}
		}

		private function onFault( inEvent : FaultEvent ) : void
		{
			fail( inEvent.fault.getStackTrace() );
		}

		private function onResult( inEvent : ResultEvent ) : void
		{
			complete( inEvent.result );
		}
	}
}
