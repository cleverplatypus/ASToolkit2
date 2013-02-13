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
package org.astoolkit.commons.reflection
{

	[Metadata(
		name = "AutoAssign",
		target = "setter,property",
		ownerType = "org.astoolkit.commons.configuration.api.ISelfWiring",
		repeatable = "true" )]
	[MetaArg( name = "match", type = "Class", mandatory = "false" )]
	[MetaArg( name = "order", type = "int", mandatory = "false" )]
	public class AutoAssign extends Metadata
	{

		public function get match() : Class
		{
			return getClass( "type", true );
		}

		public function get order() : int
		{
			return getNumber( "order", false );
		}
	}
}
