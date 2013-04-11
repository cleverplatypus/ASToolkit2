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
package org.astoolkit.workflow.plugin.parsley
{

	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import org.astoolkit.commons.configuration.api.IObjectConfigurer;
	import org.astoolkit.commons.wfml.ManagedObject;
	import org.astoolkit.lang.reflection.Type;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.internals.DynamicTaskLiveCycleWatcher;
	import org.astoolkit.workflow.task.parsley.SendParsleyMessage;
	import org.astoolkit.workflow.task.parsley.WaitForMessage;
	import org.spicefactory.parsley.core.context.Context;

	/**
	 * Plugin for Spicefactory Parsley aware tasks.
	 * <p>A Parsly Context object is automatically injected and
	 * made available to the workflow context</p>
	 * <p>To use it, just declare it in your app's Parsley context
	 * and inject it into the workflow's context dropins property</p>
	 *
	 * @example Adding Parsley support to a workflow
	 * <listing version="3.0">
	 * &lt;!-- declare the plugin --&gt;
	 * &lt;DynamicObject
	 *     id=&quot;parsleyPlugIn&quot;
	 *     type=&quot;{ ParsleyPlugIn }&quot;
	 *     /&gt;
	 *
	 * &lt;!-- create the drop-ins dictionary --&gt;
	 * &lt;DynamicObject
	 *     id=&quot;dropIns&quot;
	 *     &gt;
	 *     &lt;DynamicProperty
	 *         name=&quot;parsleyPlugIn&quot;
	 *         idRef=&quot;parsleyPlugIn&quot;
	 *         /&gt;
	 *     &lt;!-- other plugins and extensions here --&gt;
	 * &lt;/DynamicObject&gt;
	 *
	 * &lt;!-- assign it to a workflow context factory --&gt;
	 * &lt;DynamicObject
	 *     id=&quot;parsleyWorkflowContextFactory&quot;
	 *     type=&quot;{DefaultContextFactory}&quot;
	 *     &gt;
	 *     &lt;Property
	 *         name=&quot;dropIns&quot;
	 *         idRef=&quot;dropIns&quot;
	 *         /&gt;
	 * &lt;/DynamicObject&gt;
	 *
	 * &lt;!-- finally use the context factory in workflows --&gt;
	 * &lt;DynamicObject
	 *     id=&quot;parsleyAwareWorkflow&quot;
	 *     type=&quot;{ SendParsleyMessagesAround }&quot;
	 *     &gt;
	 *     &lt;Property name=&quot;contextFactory&quot; idRef=&quot;parsleyWorkflowContextFactory&quot;/&gt;
	 * &lt;/DynamicObject&gt;
	 * </listing>
	 *
	 * @see org.astoolkit.workflow.api.IWorkflowContext
	 * @see org.astoolkit.workflow.api.IContextPlugIn
	 */
	public class ParsleyPlugIn implements IContextPlugIn, IObjectConfigurer
	{

		private var _contextWatcher : DynamicTaskLiveCycleWatcher;

		[Inject]
		/**
		 * the injected Parsley context
		 */
		public var context : Context;


		/**
		 * @private
		 */
		public function getConfigExtensions() : Array
		{
			_contextWatcher = new DynamicTaskLiveCycleWatcher();
			_contextWatcher.contextBoundWatcher = onTaskContextBond;
			return [ SendParsleyMessage, WaitForMessage, _contextWatcher ];
		}

		public function getStatefulExtensions() : Array
		{
			return null;
		}


		public function configureObjects( inObjects : Array, inDocument : Object ) : void
		{
			if( inObjects && inObjects.length > 0 )
			{
				for each( var object : Object in inObjects )
					configureManagedObject( object );
			}
		}

		/**
		 * @private
		 */
		public function getInitialStateData( inContext : IWorkflowContext ) : Object
		{
			return {};
		}

		private function configureManagedObject( inObject : Object ) : void
		{
			if( Type.forType( inObject ).hasAnnotation( ManagedObject ) )
			{
				try
				{
					context.addDynamicObject( inObject );
				}
				finally
				{
					return;
				}
			}

		}

		private function onTaskContextBond( inTask : IWorkflowTask, inContext : IWorkflowContext ) : void
		{
			configureManagedObject( inTask );
		}
	}
}
