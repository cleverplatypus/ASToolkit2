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
package org.astoolkit.workflow.constant
{

	public final class FailurePolicy
	{
		public static const ABORT : String = "abort";

		public static const CASCADE : String = "cascade";

		public static const CONTINUE : String = "continue";

		public static const IGNORE : String = "ignore";

		public static const LOG_DEBUG : String = "log-debug";

		public static const LOG_ERROR : String = "log-error";

		public static const LOG_INFO : String = "log-info";

		public static const LOG_WARN : String = "log-warn";

		public static const SUSPEND : String = "suspend";
	}
}
