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

	import mx.core.IFactory;

	import org.astoolkit.commons.collection.DefaultIteratorFactory;
	import org.astoolkit.commons.collection.api.IIteratorFactory;
	import org.astoolkit.commons.configuration.api.IObjectConfigurer;
	import org.astoolkit.commons.eval.api.IRuntimeExpressionEvaluatorRegistry;
	import org.astoolkit.commons.factory.*;
	import org.astoolkit.commons.factory.api.IExtendedFactory;
	import org.astoolkit.commons.io.transform.DefaultDataTransformRegistry;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.config.api.IObjectPropertyDefaultValue;

	public class DefaultContextConfig implements IContextConfig
	{

		private var _classFactoryMappings : Array;

		private var _defaults : Vector.<IObjectPropertyDefaultValue>

		private var _inputFilterFactory : IIODataTransformerRegistry;

		private var _iteratorFactory : IIteratorFactory;

		private var _objectConfigurers : Vector.<IObjectConfigurer>;

		private var _propertyOverrideRule : IPropertyOverrideRule;

		private var _runtimeExpressionEvalutators : IRuntimeExpressionEvaluatorRegistry;

		private var _templateRegistry : ITaskTemplateRegistry;

		public function get classFactoryMappings() : Array
		{
			return _classFactoryMappings;
		}

		[ArrayItemType( "org.astoolkit.commons.factory.ClassFactoryMapping" )]
		public function set classFactoryMappings( inValue : Array ) : void
		{
			_classFactoryMappings = inValue;

		}

		public function get dataTransformerRegistry() : IIODataTransformerRegistry
		{
			return _inputFilterFactory;
		}

		public function set dataTransformerRegistry( inValue : IIODataTransformerRegistry ) : void
		{
			_inputFilterFactory = inValue;
		}

		public function get defaults() : Vector.<IObjectPropertyDefaultValue>
		{
			return _defaults;
		}

		public function set defaults( value : Vector.<IObjectPropertyDefaultValue> ) : void
		{
			_defaults = value;
		}

		public function get iteratorFactory() : IIteratorFactory
		{
			return _iteratorFactory;
		}

		public function set iteratorFactory( inValue : IIteratorFactory ) : void
		{
			_iteratorFactory = inValue;
		}

		public function get objectConfigurers() : Vector.<IObjectConfigurer>
		{
			return _objectConfigurers;
		}

		public function set objectConfigurers( value : Vector.<IObjectConfigurer> ) : void
		{
			_objectConfigurers = value;
		}

		public function get propertyOverrideRule() : IPropertyOverrideRule
		{
			return _propertyOverrideRule;
		}

		public function set propertyOverrideRule( inValue : IPropertyOverrideRule ) : void
		{
			_propertyOverrideRule = inValue;
		}

		public function get runtimeExpressionEvalutators() : IRuntimeExpressionEvaluatorRegistry
		{
			return _runtimeExpressionEvalutators;
		}

		public function set runtimeExpressionEvalutators( inValue : IRuntimeExpressionEvaluatorRegistry ) : void
		{
			_runtimeExpressionEvalutators = inValue;
		}

		public function get templateRegistry() : ITaskTemplateRegistry
		{
			return _templateRegistry;
		}

		public function set templateRegistry( inValue : ITaskTemplateRegistry ) : void
		{
			_templateRegistry = inValue;
		}

		public function getFactoryForType( inType : Class ) : IFactory
		{
			if( _classFactoryMappings )
			{
				var factory : IFactory;

				var regexp : RegExp;

				for each( var mapping : ClassFactoryMapping in _classFactoryMappings )
				{
					regexp = new RegExp(
						mapping.pattern
						.replace( /\*/g, "`" )
						.replace( /\./g, "\\." )
						.replace( /`/g, ".*" ) );

					if( getQualifiedClassName( inType ).replace( "::", "." ).match( regexp ) )
					{
						factory = mapping.factory;

						/*if( factory is IExtendedFactory )
							IExtendedFactory( factory ).type = inType;*/
						return factory;
					}

				}

			}
			return PooledFactory.create( inType, null );
		}

		public function init() : void
		{
			if( !_inputFilterFactory )
				_inputFilterFactory = new DefaultDataTransformRegistry();

			if( !_iteratorFactory )
				_iteratorFactory = new DefaultIteratorFactory();

			if( !_propertyOverrideRule )
				_propertyOverrideRule = new DefaultPropertyOverrideRule();

			if( !_templateRegistry )
				_templateRegistry = new DefaultTaskTemplateRegistry();

			if( !_runtimeExpressionEvalutators )
				_runtimeExpressionEvalutators = new DefaultRuntimeExpressionEvaluatorRegistry();
		}
	}
}
