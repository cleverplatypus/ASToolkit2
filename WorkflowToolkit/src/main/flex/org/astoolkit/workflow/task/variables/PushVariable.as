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

	import org.astoolkit.commons.utils.isCollection;
	import org.astoolkit.commons.utils.isVector;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Adds the provided value (or pipelineData) to a list type variable.
	 * If the variable doesn't exist, a new one of type <code>listType</code>
	 * (or <code>Array</code> if <code>listType</code> is not specified) is created.
	 * <p>Supported types are Array, IList and Vector.&lt;ANY&gt;</p>
	 *
	 * <p>
	 * <b>Any Input</b>
	 * </p>
	 * <p>
	 * <b>No Output</b>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>name</code>: the variable name</li>
	 * <li><code>value</code> (optional): the value to be pushed</li>
	 * <li><code>listType</code>: the destination list type</li>
	 * </ul>
	 * </p>
	 * @example Storing user answers
	 * 			<p>In the following example a set of quiz questions
	 * 			are presented to the user and the answers pushed to an ArrayCollection</p>
	 * <listing version="3.0">
	 *     &lt;Workflow dataProvider="{ _questions }"&gt;
	 *         &lt;dialog:ShowSimpleDecisionDialog
	 *             cancelButton="false"
	 *             yesButton="true"
	 *             title="Question { ENV.$i }"
	 *             text="{ ENV.$currentData.question }"
	 *             /&gt;
	 *         &lt;PushVariable
	 *             name="answers"
	 *             listType="mx.collections.ArrayCollection"
	 *             /&gt;
	 *     &lt;/Workflow&gt;
	 * </listing>
	 */
	public class PushVariable extends AbstractAddToListVariable
	{
		override protected function addValue( inList : Object, inValue : Object ) : void
		{
			if( inList is Array || isVector( inList ) )
				inList.push( inValue );
			else if( inList is IList )
				IList( inList ).addItem( inValue );

		}
	}
}
