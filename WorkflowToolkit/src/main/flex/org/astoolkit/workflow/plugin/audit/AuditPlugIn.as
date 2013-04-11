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
package org.astoolkit.workflow.plugin.audit
{

	import mx.logging.ILogger;

	import org.astoolkit.lang.util.getLogger;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.workflow.api.IContextPlugIn;
	import org.astoolkit.workflow.api.IWorkflowContext;
	import org.astoolkit.workflow.api.IWorkflowTask;

	[DefaultProperty( "targetTasks" )]
	/**
	 * Context plug-in to collect information on tasks of a running workflow
	 */
	public class AuditPlugIn implements IContextPlugIn
	{
		private const LOGGER : ILogger = getLogger( AuditPlugIn );

		public var targetTasks : Vector.<AuditTask>

		public function getConfigExtensions() : Array
		{
			return null;
		}

		public function getStatefulExtensions() : Array
		{
			return [ new AuditPlugInWatcher( this ) ];
		}


		public function getInitialStateData( inContext : IWorkflowContext ) : Object
		{
			return new AuditData();
		}


	}
}

import mx.logging.ILogger;

import org.astoolkit.lang.util.getLogger;
import org.astoolkit.workflow.api.IContextAwareElement;
import org.astoolkit.workflow.api.ITaskLiveCycleWatcher;
import org.astoolkit.workflow.api.IWorkflowContext;
import org.astoolkit.workflow.api.IWorkflowTask;
import org.astoolkit.workflow.constant.TaskPhase;
import org.astoolkit.workflow.plugin.audit.AuditData;
import org.astoolkit.workflow.plugin.audit.AuditPlugIn;
import org.astoolkit.workflow.plugin.audit.AuditTask;

class AuditPlugInWatcher implements ITaskLiveCycleWatcher, IContextAwareElement
{
	private const LOGGER : ILogger = getLogger( AuditPlugIn );

	private var _plugIn : AuditPlugIn;

	private var _context : IWorkflowContext;

	private var _auditData : AuditData;

	public function AuditPlugInWatcher( inPlugIn : AuditPlugIn )
	{
		_plugIn = inPlugIn;
	}

	public function set context( inValue : IWorkflowContext ) : void
	{
		_context = inValue;
	}

	public function get context() : IWorkflowContext
	{
		return _context;
	}

	public function onTaskPhase( inTask : IWorkflowTask, inPhase : String, inData : * = undefined ) : void
	{
		if( !_context )
			return;

		if( !_auditData )
			_auditData = AuditData( _context.getPluginData( AuditPlugIn ) );

		var info : AuditTask = getAuditSetting( inTask );

		if( !info )
			return;

		if( info.recordOutput && inPhase == TaskPhase.OUTPUT )
		{
			_auditData.pushOutputData( inTask.id, inData );
		}

		if( info.recordExitStatus && inPhase == TaskPhase.EXIT_STATUS )
		{
			_auditData.pushExitStatus( inTask.id, inData );
		}
	}

	private function getAuditSetting( inTask : IWorkflowTask ) : AuditTask
	{
		if( !_plugIn.targetTasks )
			return AuditTask.AUDIT_ALL;

		for each( var info : AuditTask in _plugIn.targetTasks )
		{
			if( !info.task )
				return info;
			else if( info.task is IWorkflowTask && info.task == inTask )
				return info;
			else if( info.task is String && info.task == inTask.id )
				return info;
			else if( info.task is Class && inTask is ( info.task as Class ) )
				return info;
		}

		return null;
	}

	public function get taskWatcherPriority() : int
	{
		return 0;
	}

	public function set taskWatcherPriority( inValue : int ) : void
	{

	}
}
