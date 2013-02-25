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
package org.astoolkit.commons.process
{

	import mx.core.mx_internal;
	import mx.rpc.AsyncToken;
	import mx.rpc.Fault;
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	import org.astoolkit.commons.process.api.IResponseSource;

	/**
	 * An AsyncToken implementing <code>IResponseSource</code>.
	 * An existing AsyncToken can be wrapped calling <code>fromAsyncToken( inToken )</code>.
	 * Methods starting async processes can have a return type of
	 * <code>IResponseSource</code> if they return a (wrapped) AsyncToken or
	 * any other implementation of the aforementioned contract.
	 */
	public class AsyncResultToken extends AsyncToken implements IResponseSource
	{

		public static function fromAsyncToken( inToken : AsyncToken ) : AsyncResultToken
		{
			var out : AsyncResultToken = new AsyncResultToken();
			out._token = inToken;
			out._token.addResponder( new PrivateResponder( out ) );
			return out;
		}

		protected var _token : AsyncToken;

		public function AsyncResultToken()
		{
			super();
		}

		public function dispatchResult( inValue : Object ) : void
		{
			mx_internal::applyResult( ResultEvent.createEvent( inValue, this ) );
		}

		public function dispatchFault( inValue : Fault ) : void
		{
			mx_internal::applyFault(
				FaultEvent.createEvent( inValue, this ) );
		}

		INTERNAL function onWrappedFault( inInfo : Object ) : void
		{
			for each( var responder : IResponder in responders )
			{
				responder.fault( inInfo );
			}
		}

		INTERNAL function onWrappedResult( inResult : Object ) : void
		{
			for each( var responder : IResponder in responders )
			{
				responder.result( inResult );
			}
		}
	}
}

//================================ IResponder implementation =================================
import mx.rpc.IResponder;

import org.astoolkit.commons.process.AsyncResultToken;

namespace INTERNAL = "org.astoolkit.common.util.AsyncResult::INTERNAL";

class PrivateResponder implements IResponder
{
	private var _owner : AsyncResultToken;

	public function PrivateResponder( inOwner : AsyncResultToken )
	{
		_owner = inOwner;
	}

	public function fault( inInfo : Object ) : void
	{
		_owner.INTERNAL::onWrappedFault( inInfo );
	}

	public function result( inData : Object ) : void
	{
		_owner.INTERNAL::onWrappedResult( inData );
	}
}
