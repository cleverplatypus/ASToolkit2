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
package org.astoolkit.commons.wfml.api
{

	/**
	 * Stereotype for an IoC component.
	 * The pid property is the container's self-wiring property name
	 * to assign the component to.
	 */
	public interface IComponent
	{
		/**
		 * the containing object's property name for declarative wiring.
		 * The purpose of this property is to simplify MXML properties declaration.
		 *
		 * @example using pid or property name node
		 * <p>In this example the <code>label</code> and <code>url</code> properties are wired
		 * respectively using the property name's node and <code>pid</code></p>
		 *
		 * <listing version="3.0">
		 * 		&lt;Link&gt;
		 * 			&lt;label&gt;
		 * 				&lt;StringBuilder&gt;...&lt;/StringBuilder&gt;
		 * 			&lt;/label&gt;
		 * 			&lt;StringBuilder pid=&quot;url&quot;&gt;&lt;/StringBuilder&gt;
		 * 		&lt;/Link&gt;
		 * </listing>
		 */
		function get pid() : String;
		function set pid( inValue : String ) : void;
	}
}
