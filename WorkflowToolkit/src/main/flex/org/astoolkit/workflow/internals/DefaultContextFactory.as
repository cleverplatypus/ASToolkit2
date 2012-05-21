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
	import org.astoolkit.workflow.api.IContextConfig;
	
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.IMXMLObject;
	
	public class DefaultContextFactory implements IFactory, IMXMLObject
	{
		private var _factory : ClassFactory;
		public var config : IContextConfig;
		public var dropIns : Object;
				
		public function newInstance():*
		{
			if( !_factory )
				_factory = new ClassFactory( DefaultWorkflowContext );
			_factory.properties = {
				config : config,
				dropIns : dropIns
			};
			return _factory.newInstance() ;
		}
		
		public function initialized(document:Object, id:String):void
		{
		}
	}
}