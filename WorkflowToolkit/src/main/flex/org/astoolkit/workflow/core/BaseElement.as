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
	import flash.utils.setTimeout;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.utils.ObjectProxy;
	
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.databinding.BindingUtility;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.commons.reflection.*;
	import org.astoolkit.commons.utils.IChildrenAwareDocument;
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
	[DefaultProperty( "autoConfigChildren" )]
	public class BaseElement extends ObjectProxy implements IWorkflowElement
	{
		/**
		 * @private
		 */
		private static const LOGGER : ILogger = getLogger( BaseElement );

		/**
		 * @private
		 */
		public function BaseElement()
		{
			super();
			_unsetProperties = {};
			_initialWatchers = {};

			for each ( var f : Field in Type.forType( this ).getFields() )
			{
				if ( f.fullAccess )
				{
					_unsetProperties[ f.name ] = true;

					_initialWatchers[ f.name ] =
						ChangeWatcher.watch(
						this, f.name, onPropertyEarlySet, false );
				}
			}
		}

		/**
		 * @private
		 */
		protected var _autoConfigChildren : Array;

		public function set autoConfigChildren( inValue : Array ) : void
		{
			_autoConfigChildren = inValue;
		}

		/**
		 * @private
		 */
		protected var _context : IWorkflowContext;

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

		/**
		 * @private
		 */
		protected var _currentIterator : IIterator;

		public function set currentIterator( inValue : IIterator ) : void
		{
			_currentIterator = inValue;
		}

		/**
		 * @private
		 */
		protected var _delegate : IWorkflowDelegate;

		public function set delegate( inDelegate : IWorkflowDelegate ) : void
		{
			_delegate = inDelegate;
		}

		/**
		 * @private
		 */
		protected var _description : String = NO_DESCRIPTION;

		/**
		 * @inheritDoc
		 */
		public function get description() : String
		{
			if ( _description != NO_DESCRIPTION )
				return _description;
			else
				return getAncestryString();
		}

		public function set description( inName : String ) : void
		{
			_description = inName;
		}

		/**
		 * @private
		 */
		protected var _document : Object;

		public function get document() : Object
		{
			return _document;
		}

		/**
		 * @private
		 */
		protected var _enabled : Boolean = true;

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

		/**
		 * @private
		 */
		protected var _id : String;

		public function get id() : String
		{
			return _id;
		}

		/**
		 * @private
		 */
		protected var _parent : IElementsGroup;

		/**
		 * @inheritDoc
		 */
		public function get parent() : IElementsGroup
		{
			return _parent;
		}

		public function set parent( inParent : IElementsGroup ) : void
		{
			_parent = inParent;
		}

		/**
		 * @private
		 */
		protected var _pid : String;

		public function get pid() : String
		{
			return _pid;
		}

		public function set pid(value:String) : void
		{
			_pid = value;
		}

		/**
		 * @private
		 */
		protected var _ancestryString : String;

		/**
		 * @private
		 */
		protected var _overriddenProperties : Array;

		/**
		 * @private
		 */
		protected var _thread : uint;

		/**
		 * @private
		 */
		protected var _unsetProperties : Object;

		/**
		 * override this getter to prevent data binding from being
		 * disabled while in idle status
		 */
		protected function get suspendBinding() : Boolean
		{
			return true;
		}

		/**
		 * @private
		 */
		private var _initialWatchers : Object;

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
			if ( !_ancestryString )
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

					if ( !task.parent )
						ancestry.unshift( getQualifiedClassName( task.document ) );
					task = task.parent;
				} while ( task != null );

				_ancestryString = "{ " + ancestry.join( " > " ) + " }";
			}
			return _ancestryString;
		}

		/**
		 * @inheritDoc
		 */
		public function initialize() : void
		{
			if ( suspendBinding && _document != null )
				BindingUtility.disableAllBindings( _document, this );

			if ( _autoConfigChildren && _autoConfigChildren.length > 0 )
			{
				var configInfo : Array = AutoConfigUtil.autoConfig( this, _autoConfigChildren );

				for each ( var prop : Object in configInfo )
				{
					if ( prop.assigned == true )
						delete _unsetProperties[ prop.name ];
					else
						LOGGER.warn( 
							"Auto config children {0} cannot be assigned",
							getQualifiedClassName( prop.object ) );
				}
			}
		}

		/**
		 * @private
		 *
		 * implementation of IMXMLObject
		 */
		public function initialized( inDocument : Object, inId : String ) : void
		{

			if ( inDocument.hasOwnProperty( "initialized" ) &&
				inDocument[ "initialized" ] == false )
			{
				setTimeout( initialized, 1, inDocument, inId );
				return;
			}

			if ( inDocument is IChildrenAwareDocument )
				IChildrenAwareDocument( inDocument ).childNodeAdded( this );
			_document = inDocument;
			_id = inId;

			for ( var name : String in _unsetProperties )
			{
				if ( BindingUtility.propertyHasBindings( _document, this, name ) )
					delete _unsetProperties[ name ];

				if ( _initialWatchers.hasOwnProperty( name ) )
					_initialWatchers[ name ].unwatch();
			}
			_initialWatchers = null;

			if ( suspendBinding && _document != null )
				BindingUtility.disableAllBindings( _document, this );
		}

		/**
		 * @inheritDoc
		 */
		public function prepare() : void
		{
		}

		/**
		 * @private
		 */
		astoolkit_private function propertyIsUserDefined( inPropertyName : String ) : Boolean
		{
			return !_unsetProperties.hasOwnProperty( inPropertyName );
		}

		/**
		 * @private
		 */
		private function onPropertyEarlySet( inEvent : PropertyChangeEvent ) : void
		{
			if ( _initialWatchers.hasOwnProperty( inEvent.property ) )
				_initialWatchers[ inEvent.property ].unwatch();

			if ( _unsetProperties.hasOwnProperty( inEvent.property ) )
				delete _unsetProperties[ inEvent.property ]
		}
		
		public function wakeup():void
		{
		}
		
		
	}
}
