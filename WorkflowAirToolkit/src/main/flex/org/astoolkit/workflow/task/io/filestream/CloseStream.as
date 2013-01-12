package org.astoolkit.workflow.task.io.filestream
{

	import flash.filesystem.FileStream;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Closes a <code>flash.filesystem.FileStream</code>.<br><br>
	 *
	 * <b>Input</b>
	 * <ul>
	 * <li>a <code>flash.filesystem.FileStream</code> object</li>
	 * </ul>
	 * <b>No Output</b>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>stream</code> (injectable): a target FileStream</li>
	 * </ul>
	 * </p>
	 */
	public class CloseStream extends BaseTask
	{

		private var _stream : FileStream;

		[InjectPipeline]
		public function set stream( inValue :FileStream) : void
		{
			_onPropertySet( "stream" );
			_stream = inValue;
		}

		override public function begin() : void
		{
			super.begin();

			if( _stream )
				_stream.close();
			complete();
		}
	}
}
