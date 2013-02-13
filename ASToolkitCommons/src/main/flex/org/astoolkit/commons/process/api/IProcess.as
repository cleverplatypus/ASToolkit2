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

	public interface IProcess
	{
		/**
		 * Execution entry point for the process.
		 * <p>The optional parameter sets the process' input</p>
		 * <p>If the process completes synchronously, this method
		 * returns the the former's output, <code>undefined</code> otherwise.</p>.
		 *
		 * <p>Asynchronous completion handling depends on the implementation.
		 * A process implementing <code>IResponseSource</code>, for instance, would handle
		 * async result/failure notifying its registered <code>IResponder</code>s.</p>
		 *
		 *
		 * @param inData optional input for the rpcess
		 *
		 * @return the process's output if the latter completes synchronously, <code>undefined</code> otherwise
		 *
		 * @example Executing a sync process.
		 * 			<p>In this example we're running a process that
		 * 			does some filtering on the input data andcompletes synchronously</p>
		 *
		 * <listing version="3.0">
		 * 		var output : Array = myProcess.run( myInputData );
		 * </listing>
		 *
		 * @example Executing an async process.
		 * 			<p>In this example we're running a process that could
		 * 			call a remote procedure to get the user profile asynchronously.
		 * 			It could however return synchronously if the requested data is cached
		 * 			locally.</p>
		 *
		 * <listing version="3.0">
		 * 		var output : Object = getUserProfile.run();
		 * 		if( output is IResponseSource  )
		 * 			IResponseSource( output ).addResponder( new Responder( onResult, onFault ) );
		 * 		else if( output is UserProfile )
		 * 			this.userProfile = UserProfile( output );
		 * </listing>
		 */
		function run( inData : * = undefined ) : *;
	}
}
