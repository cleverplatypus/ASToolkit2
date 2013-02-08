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
package org.astoolkit.workflow.api
{

	import flash.events.IEventDispatcher;

	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.wfml.IAutoConfigurable;
	import org.astoolkit.commons.wfml.IComponent;

	public interface IWorkflowElement extends IContextAwareElement, 
		IAutoConfigurable, 
		IComponent
	{
		/**
		 * @private
		 *
		 * the wrapping workflow's iterator if any
		 */
		function set currentIterator( inValue : IIterator ) : void;

		function set liveCycleDelegate( inValue : ITaskLiveCycleWatcher ) : void; //TODO: change name to something more meaningful (e.g. livecycleDelegate)
		/**
		 * an optional human readable description for this element.
		 * <p>If not defined, a string containing the branch this element
		 * belongs to is generated</p>
		 */
		function get description() : String;
		function set description( inName : String ) : void;
		/**
		 * the class defined as MXML document this element belongs to
		 */
		function get document() : Object;
		/**
		 * if false this element will be skipped
		 */
		[Inspectable( defaultValue = "true" )]
		function get enabled() : Boolean;
		function set enabled( inEnabled : Boolean ) : void;
		/**
		 * the MXML id string
		 */
		function get id() : String;
		/**
		 * the wrapping group. Null for root element
		 */
		function get parent() : ITasksGroup;
		function set parent( inParent : ITasksGroup ) : void;

		/**
		 * called when the workflow completes.
		 * <p>Implementations should override this method to release
		 * any allocated resource.</p>
		 */
		function cleanUp() : void;
		/**
		 * called by parent workflow when root workflow begins.
		 * <p>Override this method in custom elements to allocate
		 * resources which lifetime spans the root workflow's lifetime.</p>
		 * Do not call this method directly.
		 */
		function initialize() : void;

		/**
		 * called by parent group before every iteration
		 */
		function prepare() : void; //TODO: rename to something like "prepareForIteration()"?

		/**
		 * called by parent workflow before begin.
		 * <p>If this task has state, override this method and
		 * reset any value for next invocation.</p>
		 */
		function wakeup() : void;
	}
}
