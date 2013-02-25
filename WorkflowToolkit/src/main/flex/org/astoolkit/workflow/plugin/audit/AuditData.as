package org.astoolkit.workflow.plugin.audit
{

	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.utils.ObjectUtil;

	import org.astoolkit.commons.utils.getLogger;
	import org.astoolkit.workflow.core.ExitStatus;

	public class AuditData
	{
		private static const LOGGER : ILogger = getLogger( AuditData );

		private var _outputData : Object = {};

		private var _exitStatus : Object = {};

		public function pushOutputData( inId : String, inData : Object ) : void
		{
			if( !_outputData.hasOwnProperty( inId ) )
				_outputData[ inId ] = [];
			_outputData[ inId ].push( inData );
		}

		public function getOuputData( inId : String ) : Array
		{
			return _outputData[ inId ].concat();
		}

		public function pushExitStatus( inId : String, inExitStatus : ExitStatus ) : void
		{
			if( !_exitStatus.hasOwnProperty( inId ) )
				_exitStatus[ inId ] = [];
			_exitStatus[ inId ].push( inExitStatus );

		}

		public function getExitStatus( inId : String ) : Array
		{
			return _exitStatus[ inId ].concat();
		}


	}
}
