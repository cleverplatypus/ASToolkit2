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
package org.astoolkit.workflow.api
{

	import org.astoolkit.commons.collection.api.IIteratorFactory;
	import org.astoolkit.commons.eval.api.IRuntimeExpressionEvaluatorRegistry;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;

	/**
	 * Contract for in IWorkflowContext configuration object.
	 */
	public interface IContextConfig
	{
		/**
		 * an instance of <code>IIODataTransformerRegistry</code> providing
		 * access to all the registered IIODataTransformer implementations
		 * made available to the <code>IWorkflowContext</code>
		 */
		function get dataTransformerRegistry() : IIODataTransformerRegistry;
		function set dataTransformerRegistry( inValue : IIODataTransformerRegistry ) : void;
		/**
		 * called by the owner <code>IWorkflowContext</code> after
		 * setting the config's properties.
		 */
		function init() : void;
		/**
		 * an instance of <code>IIteratorFactory</code> providing
		 * access to all the registered <code>IIterator</code> implementations
		 * made available to the <code>IWorkflowContext</code>
		 */
		function get iteratorFactory() : IIteratorFactory;
		function set iteratorFactory( inValue : IIteratorFactory ) : void;
		/**
		 * an instance of <code>IPropertyOverrideRule</code> providing
		 * the rule for properties override.
		 *
		 * @see org.astoolkit.workflow.core.Group
		 */
		function get propertyOverrideRule() : IPropertyOverrideRule;
		function set propertyOverrideRule( inValue : IPropertyOverrideRule ) : void;

		function get runtimeExpressionEvalutators() : IRuntimeExpressionEvaluatorRegistry;
		function set runtimeExpressionEvalutators( inValue : IRuntimeExpressionEvaluatorRegistry ) : void;
		/**
		 * an instance of <code>IIteratorFactory</code> providing
		 * access to all the registered <code>IIterator</code> implementations
		 * made available to the <code>IWorkflowContext</code>
		 */
		function get templateRegistry() : ITaskTemplateRegistry;
		function set templateRegistry( inValue : ITaskTemplateRegistry ) : void;
	}
}
