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
package org.astoolkit.workflow.internals
{
	import flash.utils.getQualifiedClassName;
	
	import mx.logging.ILogger;
	import mx.logging.Log;
	
	import org.astoolkit.commons.factory.IPooledFactory;
	import org.astoolkit.commons.factory.PooledFactory;
	import org.astoolkit.commons.reflection.ClassInfo;
	import org.astoolkit.workflow.annotation.Template;
	import org.astoolkit.workflow.api.ITaskTemplate;
	import org.astoolkit.workflow.api.ITaskTemplateRegistry;
	import org.astoolkit.workflow.api.IWorkflowTask;
	
	public class DefaultTaskTemplateRegistry implements ITaskTemplateRegistry
	{
		private static const LOGGER : ILogger = 
			Log.getLogger( getQualifiedClassName( DefaultTaskTemplateRegistry ).replace(/:+/g, "." ) );
		
		private var _implementationsByContract : Object = {};
		
		public function registerImplementation( inImplementation : Object ) : void
		{
			var ci : ClassInfo = ClassInfo.forType( inImplementation );
			var interfaces : Vector.<ClassInfo> = 
				ci.getInterfacesWithAnnotationsOfType( Template );
			for each( var contract : ClassInfo in interfaces )
			{
				if( !_implementationsByContract.hasOwnProperty( contract.fullName ) )
				{
					var factory : PooledFactory = new PooledFactory();
					factory.defaultType = 
						inImplementation is Class ? 
							inImplementation as Class :
							inImplementation.constructor;
					_implementationsByContract[ contract.fullName ] = factory;
				}
				else
				{
					LOGGER.warn( "Template implementation '{0}' for interface '{1}' was" +
						" already registered. You might want to disable one of them.",
						getQualifiedClassName( _implementationsByContract[ contract.fullName ] ),
						contract.fullName );
				}
			}
		}
		
		public function releaseImplementation( inImplementation : IWorkflowTask ) : void
		{
			var ci : ClassInfo = ClassInfo.forType( inImplementation );
			var interfaces : Vector.<ClassInfo> = 
				ci.getInterfacesWithAnnotationsOfType( Template );
			for each( var contract : ClassInfo in interfaces )
			{
				if( _implementationsByContract.hasOwnProperty( contract.fullName ) )
				{
					var factory : PooledFactory = _implementationsByContract[ contract.fullName ];
					factory.release( inImplementation );
				}
			}
		}
		
		public function getImplementation( inTemplate : ITaskTemplate ) : IWorkflowTask
		{
			var implementation : IWorkflowTask;
			var ci : ClassInfo = ClassInfo.forType( inTemplate );
			var interfaces : Vector.<ClassInfo> = 
				ci.getInterfacesWithAnnotationsOfType( Template );
			if( interfaces && interfaces.length > 0 )
			{
				if( _implementationsByContract.hasOwnProperty( interfaces[ 0 ].fullName ) )
				{
					var factory : IPooledFactory 
						= _implementationsByContract[ interfaces[ 0 ].fullName ];
					implementation = factory.newInstance();
				}
				
			}
			return implementation;
		}
	}
}