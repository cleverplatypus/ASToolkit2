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
	import org.astoolkit.commons.collection.DefaultIteratorFactory;
	import org.astoolkit.commons.collection.api.IIteratorFactory;
	import org.astoolkit.commons.io.transform.api.IIODataTransformRegistry;
	import org.astoolkit.workflow.api.IContextConfig;
	import org.astoolkit.workflow.api.IPropertyOverrideRule;
	import org.astoolkit.workflow.inputfilter.DefaultTaskInputFilterRegistry;
	
	public class DefaultContextConfig implements IContextConfig
	{
		private var _inputFilterFactory : IIODataTransformRegistry;
		private var _propertyOverrideRule : IPropertyOverrideRule;
		private var _iteratorFactory : IIteratorFactory;
		
		public function init() : void
		{
			if( !_inputFilterFactory )
				_inputFilterFactory = new DefaultTaskInputFilterRegistry();
			if( !_iteratorFactory )
				_iteratorFactory = new DefaultIteratorFactory();
			if( !_propertyOverrideRule )
				_propertyOverrideRule = new DefaultPropertyOverrideRule();
		}
		
		public function get propertyOverrideRule() : IPropertyOverrideRule
		{
			return _propertyOverrideRule;
		}
		
		public function set propertyOverrideRule( inValue : IPropertyOverrideRule ) : void
		{
			_propertyOverrideRule = inValue;
		}

		public function get inputFilterRegistry() : IIODataTransformRegistry
		{
			return _inputFilterFactory;
		}
		
		public function set inputFilterRegistry( inValue : IIODataTransformRegistry ) : void
		{
			_inputFilterFactory = inValue;
		}
		
		public function get iteratorFactory() : IIteratorFactory
		{
			return _iteratorFactory;
		}
		
		public function set iteratorFactory( inValue : IIteratorFactory ) : void
		{
			_iteratorFactory = inValue;
		}
		
	}
}