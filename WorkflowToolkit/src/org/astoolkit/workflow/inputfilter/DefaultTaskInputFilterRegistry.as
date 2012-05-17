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

*/package org.astoolkit.workflow.inputfilter
{
	import org.astoolkit.commons.io.filter.api.IIOFilter;
	import org.astoolkit.commons.io.filter.api.IIOFilterRegistry;
	
	import flash.utils.getQualifiedClassName;
	import org.astoolkit.commons.io.filter.FunctionReferenceTaskInputFilter;
	import org.astoolkit.commons.io.filter.ObjectPropertyChainInputFilter;

	public class DefaultTaskInputFilterRegistry implements IIOFilterRegistry
	{
		private var _filters : Vector.<IIOFilter>;
		private var _filtersBySelector : Object;
		
		public function DefaultTaskInputFilterRegistry()
		{
			_filters = new Vector.<IIOFilter>();
			registerFilter( ObjectPropertyChainInputFilter );
			registerFilter( FunctionReferenceTaskInputFilter );
		}
		
		public function getFilter( inData : Object, inFilterData : Object ) : IIOFilter
		{
			for each( var f : IIOFilter in _filters )
			{
				for each( var dataType : Class in f.supportedDataTypes )
				{
					if( inData is dataType )
					{
						for each( var filterType : Class in f.supportedFilterTypes )
						{
							if( inFilterData is filterType && f.isValidFilter( inFilterData ) )
							{
								return f;
							}
						}
					}
				}
			}
			return null;
		}

		private function sortFilters( inFilterA : IIOFilter, inFilterB : IIOFilter  ) : int
		{
			if( inFilterA.priority < inFilterB.priority )
				return 1;
			else if( inFilterA.priority > inFilterB.priority )
				return -1;
			return 0;
		}
		
		public function registerFilter( inObject : Object ) : void
		{
			var o : Object = inObject is Class ? new inObject() : inObject;
			if( !( o is IIOFilter ) )
				throw new Error( "Attempt to register unrelated class " + 
					getQualifiedClassName( o ) + " as IIOFilter" );
			_filters.push( o as IIOFilter );
			_filters = _filters.sort( sortFilters );
		}
		
	}
}