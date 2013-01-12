package org.astoolkit.commons.wfml.filesystem
{

	import flash.filesystem.File;
	import org.astoolkit.commons.wfml.IComponent;

	public final class File extends flash.filesystem.File implements IComponent
	{
		private var _pid : String;

		public function get pid() : String
		{
			return _pid;
		}

		public function set pid(value:String) : void
		{
			_pid = value;
		}

		public function File()
		{
			super( null );
		}
	}
}
