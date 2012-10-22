package org.astoolkit.workflow.task.text
{

	import org.astoolkit.workflow.core.BaseTask;

	public class ReplaceText extends BaseTask
	{

		public var regexp : RegExp;

		public var replacement : String = "";

		[Bindable]
		[InjectPipeline]
		public var text : String;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !text )
			{
				fail( "Text not provided" );
				return;
			}

			if( !regexp )
			{
				fail( "Regexp not provided" );
				return;
			}

			complete( text.replace( regexp, replacement ) );
		}
	}
}
