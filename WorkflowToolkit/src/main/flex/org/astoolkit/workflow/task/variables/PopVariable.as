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
package org.astoolkit.workflow.task.variables
{

	import flash.utils.getQualifiedClassName;
	import mx.collections.IList;
	import org.astoolkit.workflow.constant.UNDEFINED;
	import org.astoolkit.workflow.internals.GroupUtil;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Removes and outputs the last element of the list variable <code>name</code>.
	 * <p>If the named list is not found <code>emptyListPolicy</code>
	 * determines the task's behaviour:
	 * <ul>
	 * <li><code>fail</code>: the task fails</li>
	 * <li><code>lastIteration</code>: if an iterator is set for the parent workflow, the iterator is aborted, otherwise the task fails</li>
	 * <li><code>returnNull</code>: the task outputs the value <code>null</code></li>
	 * <li><code>break</code>: the parent workflow is aborted</li>
	 * </ul>
	 * </p>
	 * <p>
	 * <b>Any Input</b>
	 * </p>
	 * <p>
	 * <b>Output</b>
	 * <ul>
	 * <li>The element removed from the list if the list is not emtpy or <code>null</code> if
	 * 		the list is null and <code>emptyListPolicy</code> is set to <code>returnNull</code></li>
	 * </ul>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>name</code>: the variable name</li>
	 * <li><code>emptyListPolicy</code>: either
	 * 	<code>lastIteration</code>,
	 * 	<code>fail</code>,
	 * <code>aborted</code> or
	 * <code>returnNull</code>. Default <code>fail</code></li>
	 * </ul>
	 * </p>
	 * @example Consuming a list variable
	 * 			<p>In this example the workflow runs into an infinite loop
	 * 			until the <code>onlineUsers</code> list variable is empty.</p>
	 * 			<b>The difference between <code>lastIteration</code> and <code>break</code>:</b>
	 * 			<p>The Trace task is not called if the list is empty because
	 * 			the policy is set to <code>break</code> therefore the parent
	 * 			workflow is interrupted immediately.</p>
	 * 			<p>If the policy was set to <code>lastIteration</code>
	 * 			the parent workflow would have completed for the last time
	 * 			therefore executing the Trace task.</p>
	 * <listing version="3.0">
	 * &lt;Workflow iterate="loop"&gt;
	 *     &lt;PopVariable
	 *         name="onlineUsers"
	 *         emptyListPolicy="break"
	 *         /&gt;
	 *     &lt;log:Trace
	 *         inputFilter="username"
	 *         /&gt;
	 * &lt;/Workflow&gt;
	 * </listing>
	 */
	public class PopVariable extends BaseTask
	{

		[Inspectable( enumeration="lastIteration,fail,break,returnNull", defaultValue="fail" )]
		public var emptyListPolicy : String = "fail";

		/**
		 * @private
		 */
		private var _name : String;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !_name || _name == "" )
			{
				fail( "Variable name not provided" );
				return;
			}

			if( !context.variables.variableIsDefined( _name ) )
			{
				fail( "Variable {0} doesn't exist", _name );
				return;
			}
			var varInstance : * = context.variables[ _name ];

			if( !( varInstance is Array ||
				getQualifiedClassName( varInstance ).match( /^__AS3__\.vec::Vector\.<.+>$/ ) ||
				varInstance is IList ) )
			{
				fail( "Attempt to pop data from an unknown list type" );
				return;
			}
			var out : *;

			if( varInstance is Array || getQualifiedClassName( varInstance ).match( /^__AS3__\.vec::Vector\.<.+>$/ ) )
				out = varInstance.length > 0 ? varInstance.pop() : UNDEFINED;
			else if( varInstance is IList )
				out = IList( varInstance ).length > 0 ?
					IList( varInstance ).removeItemAt( IList( varInstance ).length - 1 ) :
					undefined;

			if( out !== undefined )
				complete( out );
			else
			{
				if( emptyListPolicy == "fail" ||
					_currentIterator == null )
				{
					fail( "Destination list is empty" );
					return;
				}
				else if( _currentIterator != null && emptyListPolicy == "lastIteration" )
					_currentIterator.abort();
				else if( emptyListPolicy == "break" )
					GroupUtil.getParentWorkflow( this ).abort();
				else if( emptyListPolicy == "returnNull" )
					complete( null );
			}
		}

		public function set name( inValue : String ) : void
		{
			if( inValue )
				_name = inValue.match( /^\$/ ) ? inValue : "$" + inValue;
			else
				_name = null;
		}
	}
}
