package org.astoolkit.commons.io.data
{

	import org.astoolkit.commons.io.data.api.IDataProvider;
	import org.astoolkit.commons.process.api.IDeferrableProcess;
	import org.astoolkit.commons.wfml.IAutoConfigContainerObject;
	import org.astoolkit.commons.wfml.IComponent;

	[DefaultProperty("autoConfigChildren")]
	public class DateFormatter implements IDataProvider, IComponent, IAutoConfigContainerObject, IDeferrableProcess
	{
		private var _format : String;

		private var _sourceText:String;

		public function set autoConfigChildren(inValue:Array) : void
		{
			// TODO Auto Generated method stub

		}

		public function set format(value:String) : void
		{
			_format = value;
		}

		public function get pid() : String
		{
			return null;
		}

		public function set pid(inValue:String) : void
		{
		}

		public function get providedType() : Class
		{
			return null;
		}

		[AutoConfig]
		public function set sourceText( inValue : String ) : void
		{
			_sourceText = inValue;
		}

		public function addDeferredProcessWatcher(inWatcher:Function) : void
		{
			// TODO Auto Generated method stub

		}

		public function getData() : *
		{
			return null;
		}

		public function initialized(document:Object, id:String) : void
		{
			// TODO Auto Generated method stub

		}

		public function isProcessDeferred() : Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}
	}
}