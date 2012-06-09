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
	import avmplus.getQualifiedClassName;
	
	import mx.collections.IList;
	
	import org.astoolkit.workflow.core.BaseTask;
	
	/**
	 * Converts lists among <code>Array, Vector.&lt;&#42;&gt;, IList</code> types.
	 * <p>
	 * <b>Input</b>
	 * <ul>
	 * <li>any <code>Array, Vector.&lt;&#42;&gt;, IList</code> object</li>
	 * </ul>
	 * </p>
	 * <b>Output</b>
	 * <p>A new list of type <code>outputType</code> 
	 * containing the input list's elements</p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>source</code> (injectable): a <code>Array, Vector.&lt;&#42;&gt;, IList</code> object</li>
	 * <li><code>outputType</code>: the list output class, either <code>Array, Vector.&lt;&#42;&gt;, IList</code></li>
	 * </ul>
	 * </p>
	 * @example Converting an <code>ArrayCollection</code> into a typed <code>Vector</code>
	 * 			<p>In the below example, a GetWishList message is sent 
	 * 			task retrieves a list of Product. The output is likely to be 
	 * 			a generic <code>ArrayCollection</code>.</p>
	 * 			<p>If our (hypothetical) <code>DisplayProducts</code> expects a Vector.&lt;Product&gt;
	 * 			as input, we can use <code>ConvertList</code> to convert the list
	 * 			in the pipeline.</p>
	 * 			<p><em>Notice: angle brackets are escaped
	 * 			(<code>Vector.&amp;amp;lt;Product&amp;amp;gt;</code>) as they cannot be used inside an
	 * 			XML attribute.</em></p>
	 * 			
	 * <listing version="3.0">
	 * &lt;msg:SendMessage
	 *     message=&quot;{ GetWishList }&quot;
	 *     /&gt;
	 * &lt;misc:ConvertList
	 *     outputType=&quot;{ Vector.&amp;amp;lt;Product&amp;amp;gt; }&quot;
	 *     /&gt;
	 * &lt;view:DisplayProducts /&gt;
	 * </listing>
	 */ 	
	public class ConvertList extends BaseTask
	{
		[Bindable][InjectPipeline]
		/**
		 * a <code>Array, Vector.&lt;&#42;&gt;, IList</code> object
		 */
		public var source : Object;
		
		/**
		 * the list output class, either <code>Array, Vector.&lt;&#42;&gt;, IList</code>
		 */
		public var outputType : * = Array;
		
		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();
			if( !source ||
				( !( source is Array ) && 
					!getQualifiedClassName( source ).match( /^__AS3__\.vec::Vector\.<.+>$/ ) &&
					!(source is IList ) ) )
			{
				fail( "No suitable source list provided" );
				return;
			}
			if( !outputType ||
				( !( outputType is Array ) && 
					!getQualifiedClassName( outputType ).match( /^__AS3__\.vec::Vector\.<.+>$/ ) &&
					!(outputType is IList ) ) )
			{
				fail( "No supported outputType provided" );
				return;
			}
				
			var out : * = new outputType();
			for each( var item : * in source )
			{
				if( out is Array || getQualifiedClassName( out ).match( /^__AS3__\.vec::Vector\.<.+>$/ ) )
					out.push( item );
				else if( out is IList )
					out.addItem( item );
			}
			complete( out );
		}
	}
}