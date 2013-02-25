package org.astoolkit.test.invoke.controller
{

	import flash.utils.setTimeout;

	import org.astoolkit.commons.process.AsyncResultToken;
	import org.astoolkit.commons.process.api.IResponseSource;

	public class InvokeTestController
	{

		private var _token : AsyncResultToken;

		public function simpleCall() : Boolean
		{
			return true;
		}

		public function squareRoot( inValue : int ) : int
		{
			return Math.sqrt( inValue );
		}

		public function stringToUppercaseAsync( inValue : String ) : IResponseSource
		{
			_token = new AsyncResultToken();
			setTimeout( stringToUppercaseAsyncResult, 500, inValue );
			return _token;
		}

		private function stringToUppercaseAsyncResult( inValue : String ) : void
		{
			_token.dispatchResult( inValue.toUpperCase() );
			_token = null;
		}




	}
}
