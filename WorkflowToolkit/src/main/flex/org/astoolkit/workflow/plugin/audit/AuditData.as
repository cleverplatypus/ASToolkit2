package org.astoolkit.workflow.plugin.audit
{

	import flash.utils.getQualifiedClassName;

	import mx.logging.ILogger;
	import mx.utils.ObjectUtil;

	import org.astoolkit.commons.utils.getLogger;

	public class AuditData
	{
		private static const LOGGER : ILogger = getLogger( AuditData );

		private var _outputData : Object = {};

		public function pushOutputData( inId : String, inData : Object ) : void
		{
			if( !_outputData.hasOwnProperty( inId ) )
				_outputData[ inId ] = [];
			_outputData[ inId ].push( inData );
		}

		public function getOuputData( inId : String ) : Array
		{
			return _outputData[ inId ];
		}
	}
}
