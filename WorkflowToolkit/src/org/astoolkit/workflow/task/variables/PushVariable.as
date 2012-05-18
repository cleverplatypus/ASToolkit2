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
	import avmplus.getQualifiedClassName;
	
	import org.astoolkit.workflow.core.BaseTask;
	
	import flash.utils.getDefinitionByName;
	
	import mx.collections.IList;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	
	public class PushVariable extends BaseTask
	{
		public var name : String;
		public var listType : IFactory = new ClassFactory( Array );
		
		override public function begin() : void
		{
			super.begin();
			var varInstance : * = listType.newInstance();
			if( context.variables.hasOwnProperty( name ) )
			{
				if(  getQualifiedClassName( varInstance) != getQualifiedClassName( context.variables[ name ] ) ) 
				{
					fail( "Attempt to push pipeline data to a non-list variable" );
					return;
				}
				else
					varInstance = context.variables[ name ];
			}
			if( !context.variables.hasOwnProperty( name ) )
				context.variables[ name ] = varInstance;
			if( varInstance is Array )
				( varInstance as Array ).push( filteredInput );
			else if( varInstance is IList ) 
				IList( varInstance ).addItem( filteredInput );
			else
			{
				fail( "Attempt to push pipeline data to an unknown list type" );
				return;
			}
			complete();
		}
		
		
	}
}