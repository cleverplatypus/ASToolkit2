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
package org.astoolkit.commons.process.api
{

	/**
	 * contract for an object representing a process which could be
	 * suspended at some point in its livecycle.
	 * Client objects can add a watcher that will be informed when
	 * the process can resume.
	 * The process doesn't resume automatically. It's up to the watcher to perform the
	 * appropriate action, e.g. myProcess.resume();
	 * Typically, this API is used for processes that need to perform config operations
	 * before starting, where the latter could complete asynchronously.
	 */
	public interface IDeferrableProcess
	{
		/*
			TODO:  	add IDeferrableProcessWatcher and use it instead of function reference.
					should the watcher handle failure/abort too?
		*/
		function addDeferredProcessWatcher( inWatcher : Function ) : void;
		function isProcessDeferred() : Boolean;
	}
}
