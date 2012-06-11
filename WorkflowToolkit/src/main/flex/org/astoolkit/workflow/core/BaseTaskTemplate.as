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
package org.astoolkit.workflow.core
{
	
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;
	import mx.utils.ObjectUtil;
	import org.astoolkit.workflow.api.ITaskTemplate;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.api.IWorkflowTask;
	use namespace flash_proxy;
	
	public class BaseTaskTemplate extends Group implements ITaskTemplate
	{
		private var _tempImplementationProperties : Object = {};
		
		private var _templateImplementation : IWorkflowTask;
		
		override public function set children( inChildren : Vector.<IWorkflowElement> ) : void
		{
			throw new Error( "BaseTaskTemplate cannot have children assigned" );
		}
		
		override public function cleanUp() : void
		{
			_children.length = 0;
			context.config.templateRegistry.releaseImplementation( _templateImplementation );
			_templateImplementation = null;
		}
		
		override public function initialize() : void
		{
			super.initialize();
			_templateImplementation = context.config.templateRegistry.getImplementation( this );
			
			if(_templateImplementation)
			{
				for(var key : String in _tempImplementationProperties)
					_templateImplementation[key] = _tempImplementationProperties[key];
				_templateImplementation.delegate = _delegate;
				_templateImplementation.context = context;
				_templateImplementation.initialized( _document, id + "_impl" );
				_templateImplementation.parent = parent;
				_children = new <IWorkflowElement>[ _templateImplementation ];
			}
			else
			{
				throw new Error( "Template " + getQualifiedClassName( this ) +
					" has no available implementation." );
			}
		}
		
		public function get templateContract() : Class
		{
			return null;
		}
		
		public function get templateImplementation() : IWorkflowTask
		{
			return _templateImplementation;
		}
		
		protected function setImplementationProperty( inName : String, inValue : * ) : void
		{
			if(_templateImplementation)
				_templateImplementation[inName] = inValue;
			else
				_tempImplementationProperties[inName] = inValue;
		}
		
		flash_proxy override function setProperty( inName : *, inValue : * ) : void
		{
			super.flash_proxy::setProperty( inName, inValue );
			
			if(_templateImplementation &&
				(ObjectUtil.isDynamicObject( _templateImplementation ) ||
				Object( _templateImplementation ).hasOwnProperty( QName( inName ).localName )))
			{
				_templateImplementation[QName( inName ).localName] = inValue;
			}
		}
	}
}
