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
package org.astoolkit.workflow.internals
{

	import mx.utils.ArrayUtil;
	import org.astoolkit.commons.collection.api.IRepeater;
	import org.astoolkit.commons.reflection.AnnotationUtil;
	import org.astoolkit.commons.reflection.ClassInfo;
	import org.astoolkit.commons.reflection.FieldInfo;
	import org.astoolkit.workflow.annotation.OverrideChildrenProperty;
	import org.astoolkit.workflow.api.*;
	import org.astoolkit.workflow.core.Insert;

	public final class GroupUtil
	{
		private static var __injectPipelineMetaTags : Object = {};

		private static var __overrideChildrenPropertyMetaTags : Object = {};

		public static function getInserts( inWorkflow : IWorkflow ) : Vector.<IWorkflowElement>
		{
			var out : Vector.<IWorkflowElement> = new Vector.<IWorkflowElement>();

			for each( var insertEntry : Insert in inWorkflow.insert )
			{
				var taskParent : IElementsGroup = insertEntry.parent;

				if( insertEntry.relativeTo != null )
					taskParent = insertEntry.relativeTo.parent;

				if( taskParent == inWorkflow )
				{
					out = out.concat( insertEntry.elements );
				}
			}
			return out;
		}

		public static function getOverrideSafeValue( inTask : IWorkflowTask, inProperty : String ) : *
		{
			var out : * = inTask[ inProperty ];
			var parent : IElementsGroup = inTask.parent;
			var rule : IPropertyOverrideRule = inTask.context.config.propertyOverrideRule;

			while( !( parent is IWorkflow ) )
			{
				if( !groupOverridesProperty( parent, inProperty ) )
					break;

				if( rule.shouldOverride( inProperty, inTask, parent ) )
					out = parent[ inProperty ];
				parent = parent.parent;
			}
			return out;
		}

		public static function getParentRepeater( inElement : IWorkflowElement, inParentCount : int = 0 ) : IRepeater
		{
			while( inElement.parent != null && inParentCount > -1 )
			{
				if( inElement.parent is IRepeater )
					inParentCount--;
				inElement = inElement.parent;
			}
			return inElement as IRepeater;
		}

		public static function getParentWorkflow( inElement : IWorkflowElement ) : IWorkflow
		{
			while( inElement.parent != null && !( inElement.parent is IWorkflow ) )
				inElement = inElement.parent;
			return inElement.parent as IWorkflow;
		}

		public static function getRuntimeElements( inElements : Vector.<IWorkflowElement> ) : Vector.<IWorkflowElement>
		{
			return recursivelyFindMyElements( addInserts( inElements ) );
		}

		public static function getRuntimeOverridableTasks( inElements : Vector.<IWorkflowElement> ) : Vector.<IWorkflowTask>
		{
			return recursivelyFindMyTasks( addInserts( inElements ), true );
		}

		public static function getRuntimeTasks( inElements : Vector.<IWorkflowElement> ) : Vector.<IWorkflowTask>
		{
			return recursivelyFindMyTasks( addInserts( inElements ) );
		}

		private static function addInserts( inElements : Vector.<IWorkflowElement> ) : Vector.<IWorkflowElement>
		{
			var out : Vector.<IWorkflowElement> = inElements.concat();

			if( !inElements || inElements.length == 0 )
				return out;
			var thisParent : IElementsGroup = IWorkflowElement( inElements[ 0 ] ).parent;
			var aParent : IElementsGroup = thisParent;

			while( aParent != null )
			{
				for each( var insertEntry : Insert in aParent.insert )
				{
					var taskParent : IElementsGroup = insertEntry.parent;

					if( insertEntry.relativeTo != null )
						taskParent = insertEntry.relativeTo.parent;

					if( taskParent == thisParent )
					{
						var insertionPoint : int;

						if( insertEntry.relativeTo != null )
						{
							var i : int;

							for( i = 0; i < out.length; i++ )
							{
								if( insertEntry.relativeTo == out[ i ] )
								{
									break;
								}
							}
							insertionPoint = insertEntry.mode == Insert.BEFORE ? i : i + 1;
						}
						else
						{
							// if children length == 0 we always add the task starting at 0,
							// otherwise depending on the position value we add 
							// to the beginning or end of the tasks array
							insertionPoint = out.length > 0 ?
								( insertEntry.mode == Insert.BEFORE ? 0 : out.length ) : 0;
						}

						for each( var element : IWorkflowElement in insertEntry.elements )
						{
							element.parent = taskParent;
							out.splice( insertionPoint, 0, element );
							insertionPoint++;
						}
					}
				}
				aParent = aParent.parent;
			}
			return out;
		}

		private static function groupOverridesProperty( inGroup : IElementsGroup, inProperty : String ) : Boolean
		{
			if( inGroup is IRuntimePropertyOverrideGroup )
				return IRuntimePropertyOverrideGroup( inGroup ).propertyShouldOverride( inProperty );
			else
				return ClassInfo.forType( inGroup ).getField( inProperty ).hasAnnotation( OverrideChildrenProperty );
		}

		private static function recursivelyFindMyElements( inElements : Vector.<IWorkflowElement> ) : Vector.<IWorkflowElement>
		{
			var out : Vector.<IWorkflowElement> = new Vector.<IWorkflowElement>();

			for each( var element : IWorkflowElement in inElements )
			{
				out.push( element );

				if( element is IElementsGroup )
					out = out.concat( getRuntimeTasks( IElementsGroup( element ).children ) );
			}
			return out;
		}

		private static function recursivelyFindMyTasks( inElements : Vector.<IWorkflowElement>, inSkipWorkflowChildren : Boolean = false ) : Vector.<IWorkflowTask>
		{
			var out : Vector.<IWorkflowTask> = new Vector.<IWorkflowTask>();

			for each( var element : IWorkflowElement in inElements )
			{
				if( element is IWorkflowTask )
					out.push( element );
				else if( element is ITaskTemplate )
					out.push( ITaskTemplate( element ).templateImplementation );
				else if( element is IElementsGroup )
				{
					if( !( element is IWorkflow ) || !inSkipWorkflowChildren )
						out = out.concat( getRuntimeTasks( IElementsGroup( element ).children ) );
				}
			}
			return out;
		}
	}
}
