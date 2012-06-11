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
package org.astoolkit.commons.collection.api
{
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.core.IFactory;
	
	[Bindable]
	/**
	 * A contract for a data based loop provider.
	 */
	public interface IRepeater
	{
		/**
		 * the data source
		 */
		function get dataProvider() : Object;
		function set dataProvider( inValue : Object ) : void;
		function get iterator() : IIterator;
		/**
		 * an instance of <code>IIterator</code> appropriate
		 * for the data source type
		 */
		function set iterator( inValue : IIterator ) : void;
		/**
		 * a dictionary of properties to be assigned to the iterator
		 * at instanciation time.
		 */
		function set iteratorConfig( inValue : Object ) : void;
	}
}
