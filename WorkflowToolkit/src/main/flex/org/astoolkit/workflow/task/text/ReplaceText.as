package org.astoolkit.workflow.task.text
{

	import org.astoolkit.workflow.core.BaseTask;

	public class ReplaceText extends BaseTask
	{

		private var _text : String;

		public var regexp : RegExp;

		public var replacement : String = "";

		[InjectPipeline]
		public function set text( inValue :String) : void
		{
			_onPropertySet( "text" );
			_text = inValue;
		}

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !_text )
			{
				fail( "Text not provided" );
				return;
			}

			if( !regexp )
			{
				fail( "Regexp not provided" );
				return;
			}

			complete( _text.replace( regexp, replacement ) );
		}
	}
}
