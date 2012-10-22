package org.astoolkit.workflow.task.io
{

	import flash.filesystem.File;
	import org.astoolkit.workflow.core.BaseTask;

	public class ResolveFilePath extends BaseTask
	{

		public var path : String;

		[Bindable]
		[InjectPipeline]
		public var sourceFile : File;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !sourceFile )
			{
				fail( "sourceFile is not set" );
				return;
			}
			complete( sourceFile.resolvePath( path ) );
		}
	}
}
