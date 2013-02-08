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
package org.astoolkit.workflow.map
{

	import flash.utils.getQualifiedClassName;

	import mx.binding.utils.BindingUtils;
	import mx.core.IMXMLObject;

	import org.astoolkit.commons.mapping.api.IPropertyMappingDescriptor;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.workflow.api.ITasksGroup;
	import org.astoolkit.workflow.api.IWorkflowContext;
	import org.astoolkit.workflow.api.IWorkflowTask;

	[DefaultProperty( "mappings" )]
	internal class AbstractMappingProvider implements IPropertyMappingDescriptor, IMXMLObject
	{

		public function AbstractMappingProvider()
		{
			if( getQualifiedClassName( this ) == getQualifiedClassName( AbstractMappingProvider ) )
			{
				throw new Error( getQualifiedClassName( this ) + " is abstract" );
			}
		}

		public var mappings : Vector.<Mapping>;

		protected var _context : IWorkflowContext;

		private var _strict : Boolean;

		public function getMapping() : Object
		{
			var out : Object = {};

			for each( var entry : Mapping in mappings )
			{
				out[ entry.target ] = entry.source;
			}
			return out;
		}

		public function getTarget() : *
		{
			return undefined;
		}

		public function initialized( inDocument : Object, inId : String ) : void
		{
			if( !inDocument is ITasksGroup )
				throw new Error( getQualifiedClassName( this ) +
					" can only be used in a Workflow" );
			BindingUtils.bindSetter( onContextChange, inDocument, "context" );
		}

		public function set strict( inValue : Boolean ) : void
		{
			_strict = inValue;
		}

		public function get strict() : Boolean
		{
			return _strict;
		}

		private function onContextChange( inValue : IWorkflowContext ) : void
		{
			_context = inValue;
		}
	}
}
