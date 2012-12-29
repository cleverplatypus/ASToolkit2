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
/**
 * Data source resolver delegate for ASToolkit Commons conditional API.
 *
 * Supports context's data, rawData, currentData<i>n</i> i<i>n</i>, exitStatus and custom variables.
 * The default source is context's data.
 */
package org.astoolkit.workflow.conditional
{
	
	import org.astoolkit.commons.io.transform.api.IIODataSourceResolverDelegate;
	import org.astoolkit.workflow.api.IContextAwareElement;
	import org.astoolkit.workflow.api.IWorkflowContext;
	
	public class WorkflowDataSourceResolverDelegate implements IIODataSourceResolverDelegate, IContextAwareElement
	{
		private var _context : IWorkflowContext;
		
		public function WorkflowDataSourceResolverDelegate( inContext : IWorkflowContext ) : void
		{
			_context = inContext;
		}
		
		public function resolveDataSource(inSourceDescriptor:Object, inNextDelegate:IIODataSourceResolverDelegate) : *
		{
			if ( inSourceDescriptor is String )
			{
				var sourceName : String = inSourceDescriptor as String;
				
				switch ( sourceName )
				{
					case "$exitStatus":
					case "exitStatus":
						return _context.variables.$exitStatus.code;
					case "$data":
					case "data":
					case "":
						return _context.variables.$data;
					case "$rawData":
					case "rawData":
						return _context.variables.$rawData;
				}
				
				if ( sourceName.match( /^\$?currentData([0-9]+)?$/ ) )
				{
					if ( !sourceName.match( /^\$/ ) )
						sourceName = "$" + sourceName;
					return _context.variables[ sourceName ];
				}
				
				if ( sourceName.match( /^\$?i([0-9]+)?$/ ) )
				{
					if ( !sourceName.match( /^\$/ ) )
						sourceName = "$" + sourceName;
					return _context.variables[ sourceName ];
				}
			}
			return null;
		}
		
		public function set context( inValue : IWorkflowContext ) : void
		{
			_context = inValue;
		}
		
		public function get context() : IWorkflowContext
		{
			return _context;
		}
	}
}