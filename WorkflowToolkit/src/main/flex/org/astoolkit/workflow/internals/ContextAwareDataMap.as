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

	import mx.utils.ObjectProxy;
	import org.astoolkit.commons.mapping.DataMap;
	import org.astoolkit.commons.mapping.api.IPropertiesMapper;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.workflow.api.IWorkflowContext;

	internal final class ContextAwareDataMap extends DataMap
	{

		private var _context : IWorkflowContext;

		public function ContextAwareDataMap( inContext : IWorkflowContext )
		{
			super();
			_context = inContext;
		}

		public function nextTask( inMapping : Object ) : IPropertiesMapper
		{
			if( inMapping is String )
				return property( _context.variables.astoolkit_private::nextTaskProperties, inMapping as String );
			else
				return object( _context.variables.astoolkit_private::nextTaskProperties, inMapping, true );
		}

		public function self( inMapping : Object, inStrict : Boolean = true ) : IPropertiesMapper
		{
			var proxy : SelfWrapper = new SelfWrapper( _context );
			return object( proxy, inMapping, inStrict );
		}
	}
}

import flash.utils.flash_proxy;
import mx.utils.ObjectProxy;
import mx.utils.object_proxy;
import org.astoolkit.workflow.api.ITaskLiveCycleWatcher;
import org.astoolkit.workflow.api.IWorkflowContext;
import org.astoolkit.workflow.api.IWorkflowTask;
import org.astoolkit.workflow.internals.DynamicTaskLiveCycleWatcher;

use namespace flash_proxy;

dynamic class SelfWrapper extends ObjectProxy
{

	private var _context : IWorkflowContext;

	private var _currentSelf : Object;

	private var _listener : DynamicTaskLiveCycleWatcher 
		= new DynamicTaskLiveCycleWatcher();

	public function SelfWrapper( inContext : IWorkflowContext )
	{
		_context = inContext;
		_listener.beforeTaskBeginWatcher = onBeforeTaskBegin;
		_listener.taskWatcherPriority = 12;
		_context.addTaskLiveCycleWatcher( _listener );
	}

	flash_proxy override function setProperty( inName : *, inValue : * ) : void
	{
		super.flash_proxy::setProperty( inName, inValue );
		_currentSelf[ QName( inName ).localName ] = inValue;
	}

	private function onBeforeTaskBegin( inTask : IWorkflowTask ) : void
	{
		_currentSelf = inTask;
	}
}

