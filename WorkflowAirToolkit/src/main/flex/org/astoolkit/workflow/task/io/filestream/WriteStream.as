package org.astoolkit.workflow.task.io.filestream
{
	
	import flash.filesystem.FileStream;
	import org.astoolkit.workflow.core.BaseTask;
	
	/**
	 * Writes data to a <code>flash.filesystem.FileStream</code>.<br><br>
	 * The value is written using the stream's appropriate <code>writeXXX</code>
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
	 * <li><code>data</code> (injectable): the value to write</li>
	 * </ul>
	 * </p>
	 */
	public class WriteStream extends BaseTask
	{
		public var closeAfterWrite : Boolean;
		
		[Bindable]
		[InjectPipeline]
		public var data : Object;
		
		public var stream : FileStream;
		
		override public function begin() : void
		{
			super.begin();
			
			if(!stream)
			{
				fail( "stream property not defined" );
				return;
			}
			
			if(!data)
			{
				fail( "data property not defined" );
				return;
			}
			
			if(data is String)
				stream.writeUTFBytes( data as String );
			else if(data is Boolean)
				stream.writeBoolean( data as Boolean );
			else if(data is int)
				stream.writeInt( data as int );
			else if(data is Number)
				stream.writeDouble( data as Number );
			else
				stream.writeObject( data );
			
			if(closeAfterWrite)
				stream.close();
			complete();
		}
	}
}
