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

	import flash.utils.Dictionary;
	import flash.utils.flash_proxy;
	import flash.utils.getQualifiedClassName;
	import mx.effects.Effect;
	import org.astoolkit.commons.reflection.ClassInfo;
	import org.astoolkit.workflow.api.ITaskTemplate;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.internals.HeldTaskInfo;

	use namespace flash_proxy;

	public class BaseTaskTemplate extends Group implements ITaskTemplate, IWorkflowTask
	{
		private var _tempImplementationProperties : Object = {};


		private var _templateImplementation : IWorkflowTask;

		public function abort() : void
		{
			// TODO Auto Generated method stub

		}

		public function begin() : void
		{
			// TODO Auto Generated method stub

		}

		public function get blocker() : HeldTaskInfo
		{
			// TODO Auto Generated method stub
			return null;
		}

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

		public function get currentProgress() : Number
		{
			// TODO Auto Generated method stub
			return 0;
		}

		public function set currentProgress( inValue : Number ) : void
		{
			// TODO Auto Generated method stub

		}

		public function get currentThread() : uint
		{
			// TODO Auto Generated method stub
			return 0;
		}

		public function get delay() : int
		{
			// TODO Auto Generated method stub
			return 0;
		}

		public function set delay( inDelay : int ) : void
		{
			// TODO Auto Generated method stub

		}

		public function get exitStatus() : ExitStatus
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function set exitStatus( inStatus : ExitStatus ) : void
		{
			// TODO Auto Generated method stub

		}

		public function get failureMessage() : String
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function set failureMessage( inValue : String ) : void
		{
			// TODO Auto Generated method stub

		}

		public function get filteredInput() : Object
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function get forceAsync() : Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}

		public function set forceAsync( inValue : Boolean ) : void
		{
			// TODO Auto Generated method stub

		}

		public function hold() : HeldTaskInfo
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function get ignoreOutput() : Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}

		public function set ignoreOutput( inIgnoreOutput : Boolean ) : void
		{
			// TODO Auto Generated method stub

		}

		override public function initialize() : void
		{
			super.initialize();
			_templateImplementation = context.config.templateRegistry.getImplementation( this );

			if( _templateImplementation )
			{
				for( var key : String in _tempImplementationProperties )
					_templateImplementation[ key ] = _tempImplementationProperties[ key ];
				_templateImplementation.delegate = _delegate;
				_templateImplementation.context = context;
				_templateImplementation.initialized( _document, id + "_impl" );
				_templateImplementation.parent = parent;
				_children = new Vector.<IWorkflowElement>[ _templateImplementation ];
			}
			else
			{
				throw new Error( "Template " + getQualifiedClassName( this ) +
					" has no available implementation." );
			}
		}

		public function get inlet() : Object
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function set inlet( inInlet : Object ) : void
		{
			// TODO Auto Generated method stub

		}

		public function set input( inData : * ) : void
		{
			// TODO Auto Generated method stub

		}

		public function get inputFilter() : Object
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function set inputFilter( inValue : Object ) : void
		{
			// TODO Auto Generated method stub

		}

		public function get invalidPipelinePolicy() : String
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function set invalidPipelinePolicy( inValue : String ) : void
		{
			// TODO Auto Generated method stub

		}

		public function get outlet() : Object
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function set outlet( inInlet : Object ) : void
		{
			// TODO Auto Generated method stub

		}

		public function get output() : *
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function get outputFilter() : Object
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function set outputFilter( inValue : Object ) : void
		{
			// TODO Auto Generated method stub

		}

		public function set outputKind( inValue : String ) : void
		{
			// TODO Auto Generated method stub

		}

		public function resume() : void
		{
			// TODO Auto Generated method stub

		}

		public function get running() : Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}

		public function get status() : String
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function suspend() : void
		{
			// TODO Auto Generated method stub


		}

		public function get templateContract() : Class
		{
			return null;
		}

		public function get templateImplementation() : IWorkflowTask
		{
			return _templateImplementation;
		}

		public function set timeout( inValue : int ) : void
		{
			setImplementationProperty( "timeout", inValue );

		}

		protected function setImplementationProperty( inName : String, inValue : * ) : void
		{
			if( _templateImplementation )
				_templateImplementation[ inName ] = inValue;
			else
				_tempImplementationProperties[ inName ] = inValue;
		}

		flash_proxy override function setProperty( inName : *, inValue : * ) : void
		{
			super.flash_proxy::setProperty( inName, inValue );

			if( _templateImplementation &&
				( ClassInfo.forType( _templateImplementation ).isDynamic ||
				Object( _templateImplementation ).hasOwnProperty( QName( inName ).localName ) ) )
			{
				_templateImplementation[ QName( inName ).localName ] = inValue;
			}
		}
	}
}
