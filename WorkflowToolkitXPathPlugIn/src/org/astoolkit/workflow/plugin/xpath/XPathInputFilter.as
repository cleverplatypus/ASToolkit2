package org.astoolkit.workflow.plugin.xpath
{
	import memorphic.xpath.XPathQuery;
	import memorphic.xpath.parser.XPathParser;
	
	import org.astoolkit.commons.io.filter.api.IIOFilter;
	import org.astoolkit.workflow.api.IContextPlugIn;
	
	/**
	 * Input filter for XPath expressions support.
	 * <p>It can be used as workflow context plugin.</p>
	 * <p>Requires xpath-as3 library (http://code.google.com/p/xpath-as3/)</p>
	 * 
	 * @see org.astoolkit.workflow.api.IWorkflowContext#plugins
	 * @see org.astoolkit.workflow.api.IContextConfig#inputFilterRegistry
	 * @see org.astoolkit.workflow.api.IContextPlugIn
	 * @see org.astoolkit.commons.io.filter.api.IIOFilter
	 */
	public class XPathInputFilter implements IIOFilter, IContextPlugIn
	{
		private var _priority : int;
		private var _xpathParser : XPathParser = new XPathParser();
		
		/**
		 * evaluates the inFilterData String expression (an XPath expression) on 
		 * inData (an XML object) and returns the resulting filtered object.
		 * 
		 * @example Using an XPath input filter.
		 *          <p>If <code>XPathInputFilter</code> is added to
		 * 			the workflow context drop-ins, the below workflow
		 * 			will trace the 3 email attributes</p> 
		 * <listing version="3.0">
		 * &lt;!-- the xml source --&gt;
		 * &lt;myDoc&gt;
		 *     &lt;users&gt;
		 *         &lt;user name=&quot;John White&quot; email=&quot;jwhite&#64;email.com&quot;/&gt;
		 *         &lt;user name=&quot;Ronald Crimson&quot; email=&quot;rcrimson&#64;email.com&quot;/&gt;
		 *         &lt;user name=&quot;Diana Black&quot; email=&quot;dblack&#64;email.com&quot;/&gt;
		 *     &lt;/users&gt;
		 * &lt;/myDoc&gt;
		 * 
		 * &lt;!-- the workflow. the above xml is passed as input --&gt;
		 * &lt;Workflow
		 *     inputFilter=&quot;//users/user
		 *     iterate="data"
		 *     &gt;
		 *     &lt;log:Trace
		 *         inputFilter=&quot;./&#64;email&quot;
		 *         /&gt;
		 * &lt;/Workflow&gt;
		 * </listing>
		 * 
		 * @inheritDoc
		 */
		public function filter(inData:Object, inFilterData:Object, inTarget:Object=null):Object
		{
			if( !( inData is XML ) )
				throw new Error( "Data is not XML");
			return XPathQuery.execQuery( inData as XML, inFilterData as String );
		}
		
		/**
		 * @private
		 */
		public function getExtensions() : Array
		{
			return [ XPathInputFilter ];
		}
		
		/**
		 * @private
		 */
		public function init():void
		{
			
		}

		/**
		 * @private
		 */
		public function get priority():int
		{
			return _priority;
		}
		

		/**
		 * @private
		 */
		public function set priority( inValue : int ) : void
		{
			_priority = inValue;
		}
		
		/**
		 * returns true if <code>inFilterData</code> is a valid XPath expression string
		 */
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
		
		/**
		 * @private
		 */
		public function get supportedFilterTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( String );
			return out;
		}
		
		/**
		 * @private
		 */
		public function get supportedDataTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( XML );
			return out;
		}
		
		
	}
}