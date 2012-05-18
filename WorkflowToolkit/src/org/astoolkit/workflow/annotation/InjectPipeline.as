package org.astoolkit.workflow.annotation
{
	import org.astoolkit.commons.io.transform.api.IIODataTransform;
	import org.astoolkit.commons.io.transform.api.IIODataTransformRegistry;
	import org.astoolkit.commons.reflection.Metadata;
	
	[Metadata(name="InjectPipeline", target="field")]
	[MetaArg(name="filter",type="String",mandatory="false")]
	public class InjectPipeline extends Metadata
	{		
		private var _filterFactory : IIODataTransformRegistry;
		
		public function InjectPipeline( inFilterFactory : IIODataTransformRegistry )
		{
			_filterFactory = inFilterFactory;
		}
		
		public function get filterText() : String
		{
			return getString( "filter" );
		}
		
		public function getFilterInstance( inData : Object ) : IIODataTransform
		{
			return _filterFactory.getTransformer( inData, getString( "filter" ) );
		}
		
	}
}