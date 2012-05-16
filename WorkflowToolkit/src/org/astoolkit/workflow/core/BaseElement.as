package org.astoolkit.workflow.core
{
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	import mx.binding.utils.ChangeWatcher;
	import mx.events.PropertyChangeEvent;
	import mx.utils.ObjectProxy;
	
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.databinding.BindingUtility;
	import org.astoolkit.commons.ns.astoolkit_private;
	import org.astoolkit.commons.reflection.ClassInfo;
	import org.astoolkit.commons.reflection.FieldInfo;
	import org.astoolkit.workflow.api.IElementsGroup;
	import org.astoolkit.workflow.api.IWorkflowContext;
	import org.astoolkit.workflow.api.IWorkflowDelegate;
	import org.astoolkit.workflow.api.IWorkflowElement;
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
	public class BaseElement extends EventDispatcher implements IWorkflowElement
	{
		
		/**
		 * @private
		 */
		protected var _id : String;
		/**
		 * @private
		 */
		protected var _document : Object;
		

		/**
		 * @private
		 */
		protected var _ancestryString : String;
		
		/**
		 * @private
		 */
		protected var _currentIterator : IIterator;

		/**
		 * @private
		 */
		protected var _unsetProperties : Object;
		
		/**
		 * @private
		 */
		protected var _delegate : IWorkflowDelegate;

		/**
		 * @private
		 */
		protected var _thread : uint;
		/**
		 * @private
		 */
		protected var _overriddenProperties : Array;
		/**
		 * @private
		 */
		protected var _context : IWorkflowContext;
		
		/**
		 * @private
		 */
		protected var _parent : IElementsGroup;
		/**
		 * @private
		 */
		protected var _description : String= NO_DESCRIPTION;
		/**
		 * @private
		 */
		protected var _enabled : Boolean = true;
		
		/**
		 * @private
		 */
		private var _initialWatchers : Object;
		/**
		 * @private
		 */
		public function BaseElement()
		{
			super();
			_unsetProperties = {};
			_initialWatchers  = {};
			for each( var f : FieldInfo in ClassInfo.forType( this ).getFields() )
			{
				if( f.fullAccess )
				{
					_unsetProperties[ f.name ] = true;;
					_initialWatchers[ f.name ] =
						ChangeWatcher.watch(
							this, f.name, onPropertyEarlySet, false, false ) ;
				}
			}
		}
			
		/**
		 * @private
		 */
		private function onPropertyEarlySet( inEvent : PropertyChangeEvent ) : void
		{
			if( _initialWatchers.hasOwnProperty( inEvent.property ) )
				_initialWatchers[ inEvent.property ].unwatch();
			if( _unsetProperties.hasOwnProperty( inEvent.property ) )
				delete _unsetProperties[ inEvent.property ]
		}
		
		/**
		 * @inheritDoc
		 */
		public function get description():String
		{
			if( _description != NO_DESCRIPTION )
				return _description;
			else
				return getAncestryString();
		}
		
		public function set description(inName:String):void
		{
			_description = inName;
		}
		
		/**
		 * whether this element is enabled for processing
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(inEnabled:Boolean):void
		{
			_enabled = inEnabled;
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
		
		/**
		 * @inheritDoc
		 */
		public function initialize():void
		{
			BindingUtility.disableAllBindings( _document, this );
		}
		
		
		/**
		 * @inheritDoc
		 */
		public function prepare():void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function cleanUp():void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		public function get parent():IElementsGroup
		{
			return _parent;
		}
		
		public function set parent(inParent:IElementsGroup):void
		{
			_parent = inParent;
			
		}
		
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
					task = task.parent;
				} while( task != null );
				_ancestryString = "{ " + ancestry.join( " > " ) + " }";
			}
			return _ancestryString;
		}
		
		public function set currentIterator(inValue:IIterator):void
		{
			_currentIterator = inValue;
		}
		
		public function set delegate( inDelegate : IWorkflowDelegate ) : void
		{
			_delegate = inDelegate;
		}
		

		public function get id():String
		{
			return _id;
		}
		
		/**
		 * @private
		 * 
		 * implementation of IMXMLObject
		 */
		public function initialized( inDocument : Object, inId : String ) : void
		{
			_document = inDocument;
			_id = inId;
			for( var name : String in _unsetProperties )
			{
				if( BindingUtility.propertyHasBindings( _document, this, name ) )
					delete _unsetProperties[ name ];
				if( _initialWatchers.hasOwnProperty( name ) )
					_initialWatchers[ name ].unwatch();
			}
			_initialWatchers = null;

		}
		
		/**
		 * @private
		 */
		astoolkit_private function propertyIsUserDefined( inPropertyName : String ) : Boolean
		{
			return !_unsetProperties.hasOwnProperty( inPropertyName );
		}

		public function get document():Object
		{
			return _document;
		}

		
	}
}
