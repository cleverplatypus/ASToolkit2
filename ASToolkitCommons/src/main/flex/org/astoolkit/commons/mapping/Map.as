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
package org.astoolkit.commons.mapping
{

	import mx.core.IMXMLObject;
	import mx.utils.UIDUtil;

	import org.astoolkit.commons.factory.api.IFactoryResolver;
	import org.astoolkit.commons.factory.api.IFactoryResolverClient;
	import org.astoolkit.commons.mapping.api.*;
	import org.astoolkit.commons.wfml.api.IChildrenAwareDocument;
	import org.astoolkit.commons.wfml.api.IComponent;

	//TODO: add support for classFactory injection
	/**
	 * Dynamic class to define a <code>IPropertiesMapperFactory</code>
	 * and mapping at the same time.
	 * The dynamic properties are used to create the mapping object used
	 * by the mapper returned by this factory.
	 */
	public dynamic class Map implements IPropertiesMapperFactory, IComponent, IMXMLObject, IFactoryResolverClient
	{
		private var _document : Object;

		private var _id : String;

		private var _pid : String;

		private var _target : *;

		private var _strict : Boolean;

		private var _factoryResolver : IFactoryResolver;

		public function set mappingTarget( inValue : * ) : void
		{
			_target = inValue;
		}

		public function set strict( inValue : Boolean ) : void
		{
			_strict = inValue;
		}

		public function get pid() : String
		{
			return _pid;
		}

		public function set pid( inValue : String ) : void
		{
			_pid = inValue;
		}

		public function initialized( inDocument : Object, inId : String ) : void
		{
			_document = inDocument;
			_id = inId;
		}

		public function object(
			inTarget : Object,
			inMapping : Object,
			inStrict : Boolean = true ) : IPropertiesMapper
		{
			var mapper : SimplePropertiesMapper = new SimplePropertiesMapper();

			if( _document is IChildrenAwareDocument )
				IChildrenAwareDocument( _document ).childNodeAdded( mapper );
			mapper.mapping = this;
			mapper.target = resolveTarget( inTarget );
			mapper.strict = inStrict;
			return mapper;
		}

		public function property(
			inTarget : Object,
			inPropertyName : String ) : IPropertiesMapper
		{
			return null;
		}

		protected function resolveTarget( inExplicitTarget : Object ) : *
		{
			if( inExplicitTarget )
				return inExplicitTarget;

			if( _target is String && _document.hasOwnProperty( _target ) )
				return _document[ _target ];
			return _target;
		}

		public function getInstance() : IPropertiesMapper
		{
			var mapper : SimplePropertiesMapper = new SimplePropertiesMapper();

			if( _document is IChildrenAwareDocument )
				IChildrenAwareDocument( _document ).childNodeAdded( mapper );
			mapper.mapping = this;
			mapper.target = _target;
			mapper.strict = _strict;
			return mapper;
		}

		public function propertyIsEnumerable( inValue : * = null ) : Boolean
		{
			return inValue != "pid";
		}

		public function set factoryResolver(inValue:IFactoryResolver) : void
		{
			_factoryResolver = inValue;
		}

	}
}
