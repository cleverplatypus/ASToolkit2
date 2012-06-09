package org.astoolkit.workflow.annotation
{
	
	import org.astoolkit.commons.io.transform.api.IIODataTransformer;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	import org.astoolkit.commons.reflection.Metadata;
	
	[Metadata( name="InjectPipeline", target="field" )]
	[MetaArg( name="filter", type="String", mandatory="false" )]
	public class InjectPipeline extends Metadata
	{
		private var _filterFactoryFunction : Function;
		
		public function InjectPipeline( inFilterFactoryFunction : Function )
		{
			_filterFactoryFunction = inFilterFactoryFunction;
		}
		
		public function get filterText() : String
		{
			return getString( "filter", true );
		}
		
		public function getFilterInstance( inData : Object ) : IIODataTransformer
		{
			return IIODataTransformerRegistry( _filterFactoryFunction() ).getTransformer( inData, getString( "filter", true ) );
		}
	}
}
