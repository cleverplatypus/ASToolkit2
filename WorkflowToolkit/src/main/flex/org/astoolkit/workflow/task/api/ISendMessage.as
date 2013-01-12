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
package org.astoolkit.workflow.task.api
{

	import mx.core.IFactory;
	import org.astoolkit.commons.factory.api.IFactoryResolverClient;

	[Template]
	public interface ISendMessage extends IFactoryResolverClient
	{
		function set hasAsyncResult( inValue : Boolean ) : void;
		function set message( inMessage : Object ) : void;
		function set messageClass( inValue : Class ) : void;
		function set messageFactory( inValue : IFactory ) : void;
		function set messageMappingFailurePolicy( inValue : String ) : void;
		function set messagePropertiesMapping( inValue : Object ) : void;
		function set scope( inScope : Object ) : void;
		function set selector( inSelector : * ) : void;
	}
}
