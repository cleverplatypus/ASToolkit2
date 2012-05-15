package org.astoolkit.workflow.annotation
{
	import org.astoolkit.commons.factory.IPooledFactory;
	import org.astoolkit.commons.io.filter.api.IIOFilter;
	import org.astoolkit.commons.io.filter.api.IIOFilterRegistry;
	import org.astoolkit.commons.reflection.Metadata;
	
	[Metadata(name="InjectPipeline", target="field")]
	[MetaArg(name="filter",type="String",mandatory="false")]
	public class InjectPipeline extends Metadata
	{		
		private var _filterFactory : IIOFilterRegistry;
		
		public function InjectPipeline( inFilterFactory : IIOFilterRegistry )
		{
			_filterFactory = inFilterFactory;
		}
		
		public function get filterText() : String
		{
			return getString( "filter" );
		}
		
		public function getFilterInstance( inData : Object ) : IIOFilter
		{
			return _filterFactory.getFilter( inData, getString( "filter" ) );
		}
		
	}
}