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
package org.astoolkit.commons.databinding
{

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import mx.binding.utils.BindingUtils;
	import mx.core.IMXMLObject;
	import avmplus.getQualifiedClassName;
	import spark.core.IDisplayText;

	/**
	 * MXML component to bind properties to a handler or a setter.
	 *
	 * Bindings are suspended/reactivated when the owning document is a display object
	 * and it's added/removed from the display list.
	 */
	public class Watch implements IMXMLObject
	{

		/**
		 * @private
		 */
		private var _active : Boolean;

		/**
		 * @private
		 */
		private var _chain : String;

		/**
		 * @private
		 */
		private var _document : IEventDispatcher;

		/**
		 * @private
		 */
		private var _source : Object;

		/**
		 * @private
		 */
		private var _target : Object;

		/**
		 * @private
		 */
		private var _targetProperty : String;

		/**
		 * @private
		 */
		private var _weakFunctions : Array = [];

		public function set chain( inValue : String ) : void
		{
			_chain = inValue;
		}

		public var commitOnly : Boolean;

		[Inspectable( enumeration="always,once", defaultValue="always" )]
		public function set fire( inValue : String ) : void
		{
			//TODO: implement fire-once functionality
		}

		public function set source( inValue : * ) : void
		{
			_source = inValue;

			if( _active && _weakFunctions.length == 0 )
				fireChange( inValue );
		}

		public function set target( inValue : Object ) : void
		{
			_target = inValue;
		}

		public function set targetProperty( inValue : String ) : void
		{
			_targetProperty = inValue;
		}

		/**
		 * @private
		 */
		public function initialized( inDocument : Object, inId : String ) : void
		{
			_document = IEventDispatcher( inDocument );

			if( _document is DisplayObject )
			{
				_document.addEventListener( 
					Event.ADDED_TO_STAGE, 
					onAddedToStage, 
					false, 
					int.MAX_VALUE );
				_document.addEventListener( 
					Event.REMOVED_FROM_STAGE, 
					onRemovedFromStage, 
					false, 
					int.MAX_VALUE );
			}
			else
			{
				onAddedToStage( null );
			}
			_active = true;
		}

		/**
		 * @private
		 */
		private function bind() : void
		{
			if( _source != null )
			{
				var propChain : Object = _chain != null ? _chain.split( "." ) : null;

				if( _target != null )
					BindingUtils.bindSetter( createWeakFunction( fireChange ), _source, propChain, commitOnly, true );
			}
		}

		/**
		 * @private
		 */
		private function createWeakFunction( inFunction  : Function ) : Function
		{
			var fn : Function = function( inValue : * ) : void
			{
				fireChange( inValue );
			};
			_weakFunctions.push( fn );
			return fn;
		}

		/**
		 * @private
		 */
		private function fireChange( inValue : * ) : void
		{
			if( _target == null )
				return;

			if( _target is Function )
			{
				var fn : Function = _target as Function;

				if( ( _target as Function ).length > 0 )
					fn( inValue );
				else
					fn();
			}
			else if( _target is String && Object( _document ).hasOwnProperty( _target ) )
			{
				Object( _document )[ _target ] = inValue;
			}
			else if( _targetProperty )
			{
				var aChain : Array = _targetProperty.split( "." );
				var t : Object = _target;

				while( aChain.length > 1 )
				{
					t = t[ aChain.shift() ];
				}
				t[ aChain.shift() ] = inValue;
			}

		}

		/**
		 * @private
		 */
		private function onAddedToStage( inEvent : Event ) : void
		{
			bind();
		}

		/**
		 * @private
		 */
		private function onRemovedFromStage( inEvent : Event ) : void
		{
			_weakFunctions.length = 0;
		}
	}
}