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
	import mx.rpc.IResponder;
	import org.astoolkit.commons.databinding.BindingUtility;
	import org.astoolkit.commons.databinding.Watch;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	import org.astoolkit.commons.reflection.Type;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.workflow.api.IDeferrableProcess;
	import org.astoolkit.workflow.api.ITaskTemplate;
	import org.astoolkit.workflow.api.IWorkflowElement;
	import org.astoolkit.workflow.api.IWorkflowTask;
	import org.astoolkit.workflow.internals.DynamicTaskLiveCycleWatcher;
	import org.astoolkit.workflow.internals.HeldTaskInfo;
	import org.astoolkit.workflow.task.api.ISendMessage;
	import org.astoolkit.workflow.task.flowcontrol.IDeferrableProcessWatcher;

	use namespace flash_proxy;

	[DefaultProperty("autoConfigChildren")]
	public class BaseTaskTemplate extends Group implements ITaskTemplate, IWorkflowTask
	{

		private var _bindings : Vector.<Watch>;

		private var _implementationLiveCycleWatcher : DynamicTaskLiveCycleWatcher;

		private var _tempImplementationProperties : Object = {};

		private var _templateImplementation : IWorkflowTask;

		public function set bindings( inValue : Vector.<Watch> ) : void
		{
			_bindings = inValue;
		}

		public function get blocker() : HeldTaskInfo
		{
			return null;
		}

		override public function set children( inChildren : Vector.<IWorkflowElement> ) : void
		{
			throw new Error( "BaseTaskTemplate cannot have children assigned" );
		}

		public function get currentProgress() : Number
		{
			return 0;
		}

		public function set currentProgress( inValue : Number ) : void
		{
		}

		public function get currentThread() : uint
		{
			return 0;
		}

		public function set dataTransformerRegistry( inValue : IIODataTransformerRegistry ) : void
		{
			setImplementationProperty( "dataTransformerRegistry", inValue );
		}

		public function get delay() : int
		{
			return 0;
		}

		public function set delay( inDelay : int ) : void
		{
		}

		public function get exitStatus() : ExitStatus
		{
			return null;
		}

		public function set exitStatus( inStatus : ExitStatus ) : void
		{
		}

		public function get failureMessage() : String
		{
			return null;
		}

		public function set failureMessage( inValue : String ) : void
		{
		}

		override public function get failurePolicy() : String
		{
			return null;
		}

		override public function set failurePolicy( inValue : String ) : void
		{
			setImplementationProperty( "failurePolicy", inValue );
		}

		public function get filteredInput() : Object
		{
			return null;
		}

		public function get forceAsync() : Boolean
		{
			return false;
		}

		public function set forceAsync( inValue : Boolean ) : void
		{
		}

		public function get ignoreOutput() : Boolean
		{
			return false;
		}

		public function set ignoreOutput( inIgnoreOutput : Boolean ) : void
		{
		}

		public function get inlet() : Object
		{
			return null;
		}

		public function set inlet( inInlet : Object ) : void
		{
		}

		public function set input( inData : * ) : void
		{
		}

		public function get inputFilter() : Object
		{
			return null;
		}

		public function set inputFilter( inValue : Object ) : void
		{
		}

		public function get invalidPipelinePolicy() : String
		{
			return null;
		}

		public function set invalidPipelinePolicy( inValue : String ) : void
		{
		}

		public function get outlet() : Object
		{
			return null;
		}

		public function set outlet( inInlet : Object ) : void
		{
		}

		public function get output() : *
		{
			return null;
		}

		public function get outputFilter() : Object
		{
			return null;
		}

		public function set outputFilter( inValue : Object ) : void
		{
		}

		public function set outputKind( inValue : String ) : void
		{
		}

		public function get running() : Boolean
		{
			return false;
		}

		public function get status() : String
		{
			return null;
		}

		public function set taskParametersMapping( inValue : Object ) : void
		{
			setImplementationProperty( "parametersMapping", inValue );
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

		public function abort() : void
		{
		}

		public function addDeferredProcessWatcher( inWatcher : Function ) : void
		{
			// TODO Auto Generated method stub

		}

		public function begin() : void
		{
		}

		override public function cleanUp() : void
		{
			_children.length = 0;
			context.config.templateRegistry.releaseImplementation( _templateImplementation );
			_templateImplementation = null;
		}

		public function hold() : HeldTaskInfo
		{
			return null;
		}

		override public function initialize() : void
		{
			super.initialize();
			_templateImplementation = context.config.templateRegistry.getImplementation( this );
			_implementationLiveCycleWatcher = new DynamicTaskLiveCycleWatcher();
			_implementationLiveCycleWatcher.taskDataSetWatcher = onImplementationDataSet;
			_context.addTaskLiveCycleWatcher( _implementationLiveCycleWatcher );

			if( _templateImplementation )
			{

				for( var key : String in _tempImplementationProperties )
					_templateImplementation[ key ] = _tempImplementationProperties[ key ];

				if( _bindings )
				{
					for each( var binding : Watch in _bindings )
						binding.target = _templateImplementation;
				}
				_templateImplementation.delegate = _delegate;
				IContextAwareElement( _templateImplementation ).context = context;
				_templateImplementation.initialized( _document, id + "_impl" );
				_templateImplementation.parent = parent;
				_templateImplementation.description = description;
				_children = Vector.<IWorkflowElement>([ _templateImplementation ]);
			}
			else
			{
				throw new Error( "Template " + getQualifiedClassName( this ) +
					" has no available implementation." );
			}
		}

		public function isProcessDeferred() : Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}

		public function resume() : void
		{
		}

		public function suspend() : void
		{
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
				( Type.forType( _templateImplementation ).isDynamic ||
				Object( _templateImplementation ).hasOwnProperty( QName( inName ).localName ) ) )
			{
				_templateImplementation[ QName( inName ).localName ] = inValue;
			}
		}

		private function onImplementationDataSet( inTask : IWorkflowTask ) : void
		{
			BindingUtility.enableAllBindings( _document, this );
			BindingUtility.disableAllBindings( _document, this );
		}
	}
}
