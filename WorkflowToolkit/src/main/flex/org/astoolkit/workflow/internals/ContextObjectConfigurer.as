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

	import mx.core.IMXMLObject;
	import mx.logging.ILogger;
	import mx.utils.UIDUtil;

	import org.astoolkit.commons.conditional.api.IExpressionResolver;
	import org.astoolkit.commons.factory.api.IFactoryResolverClient;
	import org.astoolkit.commons.io.transform.api.IIODataSourceClient;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerClient;
	import org.astoolkit.commons.reflection.*;
	import org.astoolkit.commons.utils.ListUtil;
	import org.astoolkit.commons.utils.getLogger;
	import org.astoolkit.commons.utils.isCollection;
	import org.astoolkit.workflow.annotation.Featured;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.commons.configuration.api.IObjectConfigurer;
	import org.astoolkit.workflow.api.IWorkflowContext;

	public class ContextObjectConfigurer implements IObjectConfigurer
	{
		private const LOGGER : ILogger = getLogger( ContextObjectConfigurer );

		private var _configuredObjects : Object = {};

		private var _context : IWorkflowContext;

		public function ContextObjectConfigurer( inContext : IWorkflowContext )
		{
			_context = inContext;
		}

		public function configureObjects( inObjects : Array, inDocument : Object ) : void
		{
			if( inObjects && inObjects.length > 0 )
			{
				for each( var object : Object in inObjects )
					configureObject( object, inDocument );

				if( _context.config.objectConfigurers )
				{
					for each( var configurer : IObjectConfigurer in _context.config.objectConfigurers )
						configurer.configureObjects( inObjects, inDocument );
				}

			}
		}

		private function configureObject( inObject : Object, inDocument : Object ) : void
		{
			if( !_configuredObjects.hasOwnProperty( UIDUtil.getUID( inObject ) ) )
			{
				LOGGER.debug(
					"Workflow context configuring object: {0}",
					getQualifiedClassName( inObject ) );

				if( isCollection( inObject ) )
				{
					configureObjects( ListUtil.convert( inObject, Array ) as Array, inDocument );
					return;
				}

				if( inObject is IMXMLObject )
					IMXMLObject( inObject ).initialized( inDocument, null );

				if( inObject is IContextAwareElement )
					IContextAwareElement( inObject ).context = _context;

				if( inObject is IExpressionResolver )
				{
					var delegate : ContextAwareExpressionResolver = new ContextAwareExpressionResolver();
					delegate.context = _context;
					IExpressionResolver( inObject ).delegate = delegate;
				}

				if( inObject is IIODataTransformerClient )
					IIODataTransformerClient( inObject ).dataTransformerRegistry =
						_context.config.dataTransformerRegistry;

				if( inObject is IIODataSourceClient )
					IIODataSourceClient( inObject ).sourceResolverDelegate =
						_context.dataSourceResolverDelegate;

				if( inObject is IFactoryResolverClient )
					IFactoryResolverClient( inObject ).factoryResolver = _context.config;
				_configuredObjects[ UIDUtil.getUID( inObject ) ] = true;
			}

			//TODO: implement set-defaults 
			var ci : Type = Type.forType( inObject );

			for each( var fi : Field in ci.getFieldsWithAnnotation( Featured ) )
			{
				LOGGER.debug(
					"{0} has featured property: {1}",
					getQualifiedClassName( inObject ),
					fi.name );

				if( !fi.writeOnly && inObject[ fi.name ] != null )
					configureObject( inObject[ fi.name ], inDocument );
			}

		}
	}
}
