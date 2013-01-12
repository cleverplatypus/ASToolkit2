package org.astoolkit.workflow.task.io.filestream
{

	import flash.filesystem.FileStream;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Writes _data to a <code>flash.filesystem.FileStream</code>.<br><br>
	 * The value is written using the stream's appropriate <code>writeBLA</code>
	 * depending on the type passed.
	 *
	 * <b>Input</b>
	 * <ul>
	 * <li>a value to be written to the stream</li>
	 * </ul>
	 * <b>No Output</b>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>stream</code>: a destination FileStream</li>
	 * <li><code>_data</code> (injectable): the value to write</li>
	 * </ul>
	 * </p>
	 */
	public class WriteStream extends BaseTask
	{

		private var _data : Object;

		public var closeAfterWrite : Boolean;

		[InjectPipeline]
		public function set data( inValue :Object) : void
		{
			_onPropertySet( "data" );
			_data = inValue;
		}

		public var stream : FileStream;

		override public function begin() : void
		{
			super.begin();

			if( !stream )
			{
				fail( "stream property not defined" );
				return;
			}

			if( !_data )
			{
				fail( "_data property not defined" );
				return;
			}

			if( _data is String )
				stream.writeUTFBytes( _data as String );
			else if( _data is Boolean )
				stream.writeBoolean( _data as Boolean );
			else if( _data is int )
				stream.writeInt( _data as int );
			else if( _data is Number )
				stream.writeDouble( _data as Number );
			else
				stream.writeObject( _data );

			if( closeAfterWrite )
				stream.close();
			complete();
		}
	}
}
