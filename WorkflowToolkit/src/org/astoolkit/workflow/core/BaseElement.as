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
	public class BaseElement extends EventDispatcher implements IWorkflowElement
	{
		
		protected var _id : String;
		/**
		 * @private
		 */
		protected var _document : Object;
		

		protected var _ancestryString : String;
		
		protected var _currentIterator : IIterator;

		protected var _unsetProperties : Object;
		
		/**
		 * @private
		 */
		protected var _delegate : IWorkflowDelegate;

		protected var _thread : uint;
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
		
		private var _cws : Object;
		public function BaseElement()
		{
			super();
			_unsetProperties = {};
			_cws  = {};
			for each( var f : FieldInfo in ClassInfo.forType( this ).getFields() )
			{
				if( f.fullAccess )
				{
					_unsetProperties[ f.name ] = true;;
					_cws[ f.name ] =
						ChangeWatcher.watch(
							this, f.name, onPropertyEarlySet, false, false ) ;
				}
			}
		}
			
		private function onPropertyEarlySet( inEvent : PropertyChangeEvent ) : void
		{
			if( _cws.hasOwnProperty( inEvent.property ) )
				_cws[ inEvent.property ].unwatch();
			if( _unsetProperties.hasOwnProperty( inEvent.property ) )
				delete _unsetProperties[ inEvent.property ]
		}
		
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
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(inEnabled:Boolean):void
		{
			_enabled = inEnabled;
		}
		
		public function get context() : IWorkflowContext
		{
			return _context;
		}
		
		public function set context( inContext : IWorkflowContext ) : void
		{
			_context = inContext;
		}
		
		
		public function initialize():void
		{
			BindingUtility.disableAllBindings( _document, this );
		}
		
		
		public function prepare():void
		{
		}
		
		public function cleanUp():void
		{
		}
		
		public function get parent():IElementsGroup
		{
			return _parent;
		}
		
		public function set parent(inParent:IElementsGroup):void
		{
			_parent = inParent;
			
		}
		
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
				if( _cws.hasOwnProperty( name ) )
					_cws[ name ].unwatch();
			}
			_cws = null;

		}
		
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
