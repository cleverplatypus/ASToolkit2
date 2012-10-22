package org.astoolkit.commons.io.transform
{

	import org.astoolkit.commons.io.transform.api.IIODataTransformer;

	[DefaultProperty( "transformers" )]
	public class Chain extends BaseDataTransformer
	{
		private var _transformers : Vector.<IIODataTransformer>;

		override public function transform( inData : Object, inExpression : Object, inTarget : Object = null ) : Object
		{
			return inData;
		}

		public function set transformers( value : Vector.<IIODataTransformer> ) : void
		{
			_transformers = value;

			if( _transformers )
			{
				var t : IIODataTransformer = this;

				for each( var current : IIODataTransformer in _transformers )
				{
					t = t.chain( current );
				}
			}
		}
	}
}