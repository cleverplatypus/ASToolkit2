package org.astoolkit.workflow.task.io
{

	import flash.filesystem.File;
	import org.astoolkit.workflow.core.BaseTask;

	public class ResolveFilePath extends BaseTask
	{

		private var _sourceFile : File;

		public var path : String;

		[InjectPipeline]
		public function set sourceFile( inValue :File) : void
		{
			_onPropertySet( "sourceFile" );
			_sourceFile = inValue;
		}

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !_sourceFile )
			{
				fail( "sourceFile is not set" );
				return;
			}
			complete( _sourceFile.resolvePath( path ) );
		}
	}
}
