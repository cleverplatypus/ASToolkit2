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
package org.astoolkit.commons.mapping
{
	
	import mx.core.IFactory;
	import org.astoolkit.commons.io.transform.api.IIODataTransformer;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	
	public interface IPropertiesMapper
	{
		function hasTarget() : Boolean;
		function map( inSource : Object, inTarget : Object = null ) : *;
		function set mapFailDelegate( inFunction : Function ) : void;
		function mapWith( inSource : Object, inMapping : Object, inTarget : Object = null ) : *;
		function set strict( inValue : Boolean ) : void;
		function set target( inValue : Object ) : void;
		function set targetClass( inClass : IFactory ) : void;
		function set transformerRegistry( inValue : IIODataTransformerRegistry ) : void;
	}
}
