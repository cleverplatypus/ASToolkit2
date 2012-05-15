package org.astoolkit.workflow.plugin.xpath
{
	import memorphic.xpath.XPathQuery;
	import memorphic.xpath.XPathUtils;
	import memorphic.xpath.model.QueryRoot;
	import memorphic.xpath.parser.XPathParser;
	
	import org.astoolkit.commons.io.filter.api.IIOFilter;
	import org.astoolkit.workflow.api.IContextPlugIn;
	import org.astoolkit.workflow.api.IWorkflowTask;
	
	public class XPathInputFilter implements IIOFilter, IContextPlugIn
	{
		private var _priority : int;
		private var _xpathParser : XPathParser = new XPathParser();
		
		public function filter(inData:Object, inFilterData:Object, inTarget:Object=null):Object
		{
			if( !( inData is XML ) )
				throw new Error( "Data is not XML");
			return XPathQuery.execQuery( inData as XML, inFilterData as String );
		}
		
		public function getExtensions() : Array
		{
			return [ XPathInputFilter ];
		}
		
		public function init():void
		{
			
		}
		
		public function get priority():int
		{
			return _priority;
		}
		

		public function set priority( inValue : int ) : void
		{
			_priority = inValue;
		}
		
		public function isValidFilter( inFilterData : Object ) : Boolean
		{
			if( inFilterData is String )
			{
				try
				{
					new XPathParser().parseXPath( ( inFilterData as String ) );
					return true;
				}
				catch ( e : Error )
				{
				}
			}
			return false;
		}
		
		public function get supportedFilterTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( String );
			return out;
		}
		
		public function get supportedDataTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( XML );
			return out;
		}
		
		
	}
}