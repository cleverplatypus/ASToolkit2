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
	import mx.utils.ArrayUtil;
	import mx.utils.StringUtil;
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.reflection.ClassInfo;
	import org.astoolkit.workflow.annotation.OverrideChildrenProperty;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.internals.GroupUtil;
	use namespace flash_proxy;
	
	[DefaultProperty( "children" )]
	/**
	 * Simple implementation of <code>IElementsGroup</code>.
	 * <p><code>enabled</code> and <code>failurePolicy</code>, if set, override children's
	 * values.</p>
	 * <p><code>enabled</code> has a default override rule that causes
	 * overriding to occur only if this group's <code>enabled == false</code>. That's
	 * because, if the wrapping group is enabled, we still want to be able to
	 * selectively disable children tasks.</p>
	 * <p>Dynamic properties override children's properties unless listed in
	 * <code>dontOverride</code></p>
	 * @example In the following snippet, we're enabling the group's tasks
	 * 			if our (hypothetical) <code>settings.auditingEnabled == true</code>.
	 * 			<p>Notice that the <code>WriteLog</code>'s <code>enabled</code> value
	 * 			is affected only if the wrapping group's <code>enabled == false</code>.
	 * 			I.e. if the <code>settings.auditingEnabled == true</code> is enabled but
	 * 			<code>settings.loggingEnabled == false</code> , the task won't be executed.</p>
	 * <listing version="3.0">
	 * <pre>
	 * &lt;Group
	 *     enabled=&quot;{ settings.auditingEnabled }&quot;
	 *     &gt;
	 *     &lt;log:WriteLog
	 *         enabled="{ settings.loggingEnabled }"
	 *         level=&quot;info&quot;
	 *         message=&quot;Recording login failure&quot;
	 *         /&gt;
	 *     &lt;audit:Audit
	 *         entry=&quot;{ new LoginFailedAuditEvent( $.data as User ) }&quot;
	 *         /&gt;
	 * &lt;/Group&gt;
	 * </pre>
	 * </listing>
	 * @example Preventing property override
	 * 			<p>In the following example, <code>WriteLog</code>
	 * 			will inherit the <code>message</code> parameter but not
	 * 			the <code>level</code> parameter.</p>
	 * 			<p><code>Trace</code> won't inherit <code>text</code></p>
	 * <listing version="3.0">
	 * <pre>
	 * &lt;Group
	 *     message="This property will be overridden on children"
	 *     text="This won't"
	 *     level="Neither will this"
	 *     dontOverride="level,text"
	 *     &gt;
	 *     &lt;log:WriteLog
	 *         enabled="{ settings.loggingEnabled }"
	 *         /&gt;
	 *     &lt;log:Trace /&gt;
	 * &lt;/Group&gt;
	 * </pre>
	 * </listing>
	 */
	public dynamic class Group extends BaseElement implements IRuntimePropertyOverrideGroup
	{
		private var _dynamicProperties : Object = {};
		
		private var _dontOverride : Array = [];
		
		/**
		 * @private
		 */
		protected var _children : Vector.<IWorkflowElement>;
		
		/**
		 * @private
		 */
		protected var _currentThread : uint;
		
		/**
		 * @private
		 */
		protected var _tasks : Vector.<IWorkflowTask>;
		
		/**
		 * @private
		 */
		protected var _insert : Vector.<Insert>;
		
		[OverrideChildrenProperty]
		[Bindable]
		[Inspectable( defaultValue="abort", enumeration="abort,suspend,ignore,continue,log-debug,log-info,log-warn,log-error" )]
		/**
		 * Overrides children's <code>failurePolicy</code> value.
		 */
		public var failurePolicy : String;
		
		/**
		 * @private
		 */
		public function set insert(inInsert:Vector.<Insert>) : void
		{
			_insert = inInsert;
		}
		
		/**
		 * @private
		 */
		public function get insert() : Vector.<Insert>
		{
			return _insert;
		}
		
		/**
		 * @private
		 */
		public function get children() : Vector.<IWorkflowElement>
		{
			return _children;
		}
		
		/**
		 * @private
		 */
		public function set children( inChildren : Vector.<IWorkflowElement> ) : void
		{
			if ( _children && _children.length > 0 )
				throw new Error( "Tasks list cannot be overridden" );
			_children = inChildren;
			
			for each ( var child : IWorkflowElement in _children )
				child.parent = this;
		}
		
		[Bindable]
		[OverrideChildrenProperty]
		/**
		 * Overrides children's <code>enabled</code> value. See examples.
		 */
		override public function get enabled() : Boolean
		{
			return _enabled;
		}
		
		override public function set enabled( inEnabled : Boolean ) : void
		{
			_enabled = inEnabled;
		}
		
		/**
		 * @private
		 */
		override public function initialize() : void
		{
			super.initialize();
			
			if ( children )
			{
				for each ( var element : IWorkflowElement in children )
				{
					element.delegate = _delegate;
					element.context = _context;
					element.parent = this;
					element.initialize();
				}
			}
		}
		
		/**
		 * @private
		 */
		override public function prepare() : void
		{
			for each ( var child : IWorkflowElement in children )
				child.prepare();
		}
		
		/**
		 * @private
		 */
		override public function cleanUp() : void
		{
		}
		
		/**
		 * @private
		 */
		override public function get parent() : IElementsGroup
		{
			return _parent;
		}
		
		/**
		 * @private
		 */
		override public function set context( inContext : IWorkflowContext ) : void
		{
			super.context = inContext;
			
			for each ( var child : IWorkflowElement in children )
				child.context = inContext;
		}
		
		/**
		 * @private
		 */
		override public function set currentIterator(inValue:IIterator) : void
		{
			super.currentIterator = inValue;
			
			for each ( var child : IWorkflowElement in children )
				child.currentIterator = inValue;
		}
		
		/**
		 * @private
		 */
		public function set document( inDocument : Object ) : void
		{
			_document = inDocument;
		}
		
		override flash_proxy function setProperty( inName : *, inValue : * ) : void
		{
			super.flash_proxy::setProperty( inName, inValue );
			_dynamicProperties[ inName.localName ] = inValue;
		}
		
		public function propertyShouldOverride( inProperty : String ) : Boolean
		{
			if ( _dontOverride && ArrayUtil.getItemIndex( inProperty, _dontOverride ) > -1 )
				return false;
			return _dynamicProperties.hasOwnProperty( inProperty ) ||
				ClassInfo.forType( this ).getField( inProperty ).hasAnnotation( OverrideChildrenProperty );
		}
		
		public function set dontOverride( inValue : String ) : void
		{
			if ( inValue )
			{
				_dontOverride = StringUtil.trimArrayElements( inValue, "," ).split( "," );
			}
		}
	}
}
