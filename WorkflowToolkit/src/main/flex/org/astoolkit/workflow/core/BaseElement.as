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

	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.utils.ObjectProxy;

	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.databinding.BindingUtility;
	import org.astoolkit.commons.reflection.*;
	import org.astoolkit.commons.utils.getLogger;
	import org.astoolkit.commons.wfml.IChildrenAwareDocument;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.constant.NO_DESCRIPTION;

	[Bindable]
	/**
	 * Base implementation of <code>IWorkflowElement</code>.
	 * <p>Any non-task element must extend this class.</p>
	 * <tutorial id="tutorial23">Creating a task</tutorial>
	 *
	 * @see org.astoolkit.workflow.core.BaseTask
	 * @see org.astoolkit.workflow.core.Group
	 */
	[DefaultProperty( "selfWiringChildren" )]
	public class BaseElement extends ObjectProxy implements IWorkflowElement
	{
		/**
		 * @private
		 */
		private static const LOGGER : ILogger = getLogger( BaseElement );

		private var _propertiesSetAtInitTime : Object = {};

		/**
		 * @private
		 */
		protected var _ancestryString : String;

		/**
		 * @private
		 */
		protected var _selfWiringChildren : Array;

		/**
		 * @private
		 */
		protected var _context : IWorkflowContext;

		/**
		 * @private
		 */
		protected var _currentIterator : IIterator;

		/**
		 * @private
		 */
		protected var _delegate : ITaskLiveCycleWatcher;

		/**
		 * @private
		 */
		protected var _description : String = NO_DESCRIPTION;

		/**
		 * @private
		 */
		protected var _document : Object;

		/**
		 * @private
		 */
		protected var _enabled : Boolean = true;

		/**
		 * @private
		 */
		protected var _id : String;

		/**
		 * @private
		 */

		protected var _onPropertySet : Function;

		/**
		 * @private
		 */
		protected var _parent : ITasksGroup;

		/**
		 * @private
		 */
		protected var _pid : String;

		protected var _propertiesDataProviderInfo : Vector.<PropertyDataProviderInfo>;

		/**
		 * @private
		 */
		protected var _thread : uint;

		/**
		 * override this getter to prevent data binding from being
		 * disabled while in idle status
		 */
		protected function get suspendBinding() : Boolean
		{
			return true;
		}

		public function set selfWiringChildren( inValue : Array ) : void
		{
			_selfWiringChildren = inValue;
		}

		/**
		 * @inheritDoc
		 */
		public function get context() : IWorkflowContext
		{
			return _context;
		}

		public function set context( inContext : IWorkflowContext ) : void
		{
			_context = inContext;
		}

		public function set currentIterator( inValue : IIterator ) : void
		{
			_currentIterator = inValue;
		}

		public function set liveCycleDelegate( inDelegate : ITaskLiveCycleWatcher ) : void
		{
			_delegate = inDelegate;
		}

		/**
		 * @inheritDoc
		 */
		public function get description() : String
		{
			if( _description != NO_DESCRIPTION )
				return _description;
			else
				return getAncestryString();
		}

		public function set description( inName : String ) : void
		{
			_description = inName;
		}

		public function get document() : Object
		{
			return _document;
		}

		/**
		 * whether this element is enabled for processing
		 */
		public function get enabled() : Boolean
		{
			return _enabled;
		}

		public function set enabled( inEnabled : Boolean ) : void
		{
			_enabled = inEnabled;
		}

		public function get id() : String
		{
			return _id;
		}

		/**
		 * @inheritDoc
		 */
		public function get parent() : ITasksGroup
		{
			return _parent;
		}

		public function set parent( inParent : ITasksGroup ) : void
		{
			_parent = inParent;
		}

		public function get pid() : String
		{
			return _pid;
		}

		public function set pid( inValue : String ) : void
		{
			_pid = inValue;
		}

		/**
		 * @private
		 */
		public function BaseElement()
		{
			super();
			_onPropertySet = onInitTimePropertySet;
		}

		/**
		 * @inheritDoc
		 */
		public function cleanUp() : void
		{
		}

		//TODO: move this away. really necessary?
		/**
		 * utility method to get a string representing the
		 * branch this element belongs to.
		 */
		public function getAncestryString() : String
		{
			if( !_ancestryString )
			{
				var ancestry : Array = [];
				var task : IWorkflowElement = this;
				var index : String;

				do
				{
					index = task.parent ?
						"[" + task.parent.children.indexOf( task ) + "]" :
						"";
					ancestry.unshift(
						getQualifiedClassName( task ).replace( /.*?::/, "" ) + index );

					if( !task.parent )
						ancestry.unshift( getQualifiedClassName( task.document ) );
					task = task.parent;
				} while( task != null );

				_ancestryString = "{ " + ancestry.join( " > " ) + " }";
			}
			return _ancestryString;
		}

		/**
		 * @inheritDoc
		 */
		public function initialize() : void
		{
			if( suspendBinding && _document != null )
				BindingUtility.disableAllBindings( _document, this );

			if( _selfWiringChildren && _selfWiringChildren.length > 0 )
			{
				_propertiesDataProviderInfo = AutoConfigUtil.autoConfig( this, _selfWiringChildren );
			}
		}

		/**
		 * @private
		 *
		 * implementation of IMXMLObject
		 */
		public function initialized( inDocument : Object, inId : String ) : void
		{
			if( _document )
				return;
			_document = inDocument;
			_id = inId;
			_onPropertySet = function( inName : String ) : void
			{
			};

			if( inDocument is IChildrenAwareDocument )
				IChildrenAwareDocument( inDocument ).childNodeAdded( this );

			for each( var f : Field in Type.forType( this ).getFields() )
			{
				if( f.fullAccess || f.writeOnly )
				{
					if( BindingUtility.propertyHasBindings( _document, this, f.name ) )
						_propertiesSetAtInitTime[ f.name ] = f.name;
				}

			}
		}

		/**
		 * @inheritDoc
		 */
		public function prepare() : void
		{
		}

		public function wakeup() : void
		{

		}

		protected function propertyWasSetExplicitly( inProperty : String ) : Boolean
		{
			return _propertiesSetAtInitTime.hasOwnProperty( inProperty );
		}

		private function onInitTimePropertySet( inName : String ) : void
		{
			_propertiesSetAtInitTime[ inName ] = inName;
		}
	}
}
