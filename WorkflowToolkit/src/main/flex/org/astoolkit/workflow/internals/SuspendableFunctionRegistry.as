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

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.getQualifiedClassName;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.rpc.AsyncToken;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.UIDUtil;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.constant.TaskStatus;

	public class SuspendableFunctionRegistry
	{
		private static const LOGGER : ILogger =
			Log.getLogger( getQualifiedClassName( SuspendableFunctionRegistry ).replace( /:+/g, "." ) );

		/**
		 * @private
		 */
		private var _resumeCallBacks : Array;

		/**
		 * @private
		 */
		private var _suspendableFunctions : Object = {};

		/**
		 * @private
		 */
		public function addResumeCallBack( inFunction : Function ) : void
		{
			if( !_resumeCallBacks )
				initResumeCallBacks();
			_resumeCallBacks.push( inFunction );
		}

		public function cleanUp() : void
		{
			clearResumeCallBack();
		}

		/**
		 * @private
		 */
		public function clearResumeCallBack() : void
		{
			_resumeCallBacks = null;
		}

		/**
		 * returns a "thread safe" function wrapper for the provided function.
		 *
		 * <p>The returned function is workflow suspended status safe too.</p>
		 */
		public function getThreadSafeFunction( inTask : IWorkflowTask, inHandler : Function ) : Function
		{
			var key : String = UIDUtil.getUID( inTask );

			if( !_suspendableFunctions.hasOwnProperty( key ) || !_suspendableFunctions[ key ].hasOwnProperty( "" + inTask.currentThread ) )
			{
				_suspendableFunctions[ key ] = {};
				_suspendableFunctions[ key ][ "" + inTask.currentThread ] = [];
			}
			var sf : SuspendableFunction = new SuspendableFunction( inTask, inHandler, this );
			_suspendableFunctions[ key ][ "" + inTask.currentThread ].push( sf );
			return sf.wrapper;
		}

		/**
		 * @private
		 */
		public function initResumeCallBacks() : void
		{
			_resumeCallBacks = [];
		}

		/**
		 * @private
		 */
		public function invokeResumeCallBacks() : void
		{
			if( _resumeCallBacks != null )
			{
				for each( var fn : Function in _resumeCallBacks )
				{
					fn();
				}
				clearResumeCallBack();
			}
		}
	}
}

import org.astoolkit.workflow.api.IWorkflowTask;
import org.astoolkit.workflow.constant.TaskStatus;
import org.astoolkit.workflow.internals.SuspendableFunctionRegistry;

class SuspendableFunction
{

	private var _handler : Function;

	private var _registry : SuspendableFunctionRegistry;

	private var _task : IWorkflowTask;

	private var _thread : uint;

	public function SuspendableFunction( inTask : IWorkflowTask, inHandler : Function, inRegistry : SuspendableFunctionRegistry )
	{
		_task = inTask;
		_thread = inTask.currentThread;
		_handler = inHandler;
		_registry = inRegistry;
	}

	public function wrapper( ... args ) : void
	{
		if( _task.currentThread != _thread )
			return;

		if( _task.status == TaskStatus.SUSPENDED )
		{
			_registry.addResumeCallBack( wrapper );
			return;
		}
		_handler.apply( _task, args );
	}
}
