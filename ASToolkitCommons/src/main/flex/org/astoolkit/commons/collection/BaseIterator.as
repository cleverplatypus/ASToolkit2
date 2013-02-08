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
package org.astoolkit.commons.collection
{

	import org.astoolkit.commons.collection.api.IIterator;

	public class BaseIterator implements IIterator
	{
		public function BaseIterator()
		{
		}

		public function set cycle( inValue : Boolean ) : void
		{

		}

		public function get isAborted() : Boolean
		{
			return false;
		}

		public function get progress() : Number
		{
			return 0;
		}

		public function set source(inValue:*) : void
		{
		}

		public function abort() : void
		{
		}

		public function current() : Object
		{
			return null;
		}

		public function currentIndex() : Number
		{
			return 0;
		}

		public function hasNext() : Boolean
		{
			return false;
		}

		public function next() : Object
		{
			return null;
		}

		public function pushBack() : void
		{
		}

		public function reset() : void
		{
		}

		public function supportsSource(inObject:*) : Boolean
		{
			return false;
		}

		public function get pid() : String
		{
			return null;
		}

		public function set pid(inValue:String) : void
		{
		}
	}
}
