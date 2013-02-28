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
package org.astoolkit.workflow.task.misc
{

	import flash.utils.getQualifiedClassName;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.utils.StringUtil;
	import org.astoolkit.commons.factory.api.IFactoryResolver;
	import org.astoolkit.workflow.api.IFactoryResolverClientTask;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Sets an object's property value.
	 * <p>
	 * <b>Input</b>
	 * <ul>
	 * <li>any value</li>
	 * </ul>
	 * </p>
	 * <p>
	 * <b>No output</b>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>value</code> (injectable): any value</li>
	 * <li><code>path</code>: the target's property path</li>
	 * <li><code>target</code>: the object to which to set the <code>property</code>.
	 * Defaults to the current document</li>
	 * </ul>
	 * </p>
	 * @example Setting the current workflow document's property value.
	 * 			<p>In the following example, <code>SendMessage</code>
	 * 			gets some data and passes it via pipeline to <code>SetProperty</code>.</p>
	 * 			<p>Since only the <code>property</code> param is set, <code>SetProperty</code>
	 * 			tries to assign the current pipeline data to <code>document.aString</code></p>
	 *
	 * <listing version="3.0">
	 * &lt;msg:SendMessage
	 *     message=&quot;{ GetSomeString }&quot;
	 *     /&gt;
	 * &lt;misc:SetProperty
	 *     path="aString"
	 *     /&gt;
	 * </listing>
	 */
	public class SetProperty extends BaseTask implements IFactoryResolverClientTask
	{
		private var _allowDefaultFactory : Boolean;

		private var _factoryResolver : IFactoryResolver;

		private var _path : String;

		private var _target : Object;

		private var _targetClass : Class;

		private var _targetFactory : IFactory;

		private var _value : *;

		public function set allowDefaultFactory( inValue : Boolean ) : void
		{
			_allowDefaultFactory = inValue;
		}

		public function set factoryResolver( inValue : IFactoryResolver ) : void
		{
			_factoryResolver = inValue;
		}

		/**
		 * the target's property path
		 */
		public function set path( inValue : String ) : void
		{
			inValue = inValue ? StringUtil.trim( inValue ) : "";

			if( inValue == "" || inValue == "." || !inValue.match( /^\w+(\.\w+)?$/ ) )
				throw new Error( "Invalid property path format" );
			_path = inValue;
		}

		/**
		 * the object to which to set the <code>property</code>.
		 * Defaults to the current document
		 */
		public function set target( value : Object ) : void
		{
			_target = value;
		}

		public function set targetClass( inValue : Class ) : void
		{
			_targetClass = inValue;
		}

		[AutoAssign]
		public function set targetFactory( inValue : IFactory ) : void
		{
			_targetFactory = inValue;
		}

		[InjectPipeline]
		[AutoAssign]
		/**
		 * any value to be set to <code>target[ property ]</code>
		 */
		public function set value( inValue : * ) : void
		{
			_onPropertySet( "value" );
			_value = inValue;
		}

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			var aTarget : Object;

			if( _target )
				aTarget = _target;
			else if( _targetFactory )
				aTarget = _targetFactory.newInstance();
			else if( _targetClass )
			{
				var factory : IFactory = _factoryResolver.getFactoryForType( _targetClass );

				if( !factory )
				{
					if( _allowDefaultFactory )
						factory = new ClassFactory( _targetClass );
					else
					{
						fail( "No factories found for '{0}'",
							getQualifiedClassName( _targetClass ) );
						return;
					}
				}

				aTarget = factory.newInstance();
			}
			else
				aTarget = _document;

			var obj : Object = aTarget;
			var segs : Array = _path.split( "." );
			var prop : String;

			if( segs.length > 1 )
			{
				prop = segs.pop();

				for each( var seg : String in segs )
				{
					if( !checkProp( obj, seg, aTarget ) )
						return;
					obj = obj[ seg ];
				}
			}
			else
				prop = _path;

			if( !checkProp( obj, prop, aTarget ) )
				return;

			if( _value != undefined )
				obj[ prop ] = _value;
			else
				obj[ prop ] = filteredInput;
			complete();

		}

		private function checkProp( inObject : Object, inProperty : String, inTarget : Object ) : Boolean
		{
			if( !inObject || !inObject.hasOwnProperty( inProperty ) )
			{
				fail( "Cannot resolve path '{0}' in object {1}",
					_path,
					getQualifiedClassName( inTarget ) );
				return false
			}
			return true;
		}
	}
}
