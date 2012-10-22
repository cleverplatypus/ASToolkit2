/*

Copyright 2009 Nicola Dal Pont

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Version 2.x

*/
package org.astoolkit.workflow.plugin.xpath
{

	import memorphic.xpath.XPathQuery;
	import memorphic.xpath.parser.XPathParser;
	
	import org.astoolkit.commons.io.transform.BaseDataTransformer;
	import org.astoolkit.commons.io.transform.api.IIODataTransformer;
	import org.astoolkit.workflow.api.IContextPlugIn;

	/**
	 * Input filter for XPath expressions support.
	 * <p>It can be used as workflow context plugin.</p>
	 * <p>Requires xpath-as3 library (http://code.google.com/p/xpath-as3/)</p>
	 *
	 * @see org.astoolkit.workflow.api.IWorkflowContext#plugins
	 * @see org.astoolkit.workflow.api.IContextConfig#dataTransformerRegistry
	 * @see org.astoolkit.workflow.api.IContextPlugIn
	 * @see org.astoolkit.commons.io.filter.api.IIOFilter
	 */
	public class XPathDataTransform extends BaseDataTransformer implements IContextPlugIn
	{
		private var _disabledExtensions : Array;

		private var _priority : int;

		private var _xpathParser : XPathParser = new XPathParser();

		public function get disabledExtensions() : Array
		{
			return _disabledExtensions;
		}

		public function set disabledExtensions( inValue : Array ) : void
		{
			_disabledExtensions = inValue;
		}

		/**
		 * @private
		 */
		public function get extensions() : Array
		{
			return [ XPathDataTransform ];
		}

		/**
		 * @private
		 */
		public function getTemplateImplementations() : Vector.<Class>
		{
			return null;
		}

		/**
		 * @private
		 */
		public function init() : void
		{
		}

		/**
		 * returns true if <code>inExpression</code> is a valid XPath expression string
		 */
		override public function isValidExpression( inExpression : Object ) : Boolean
		{
			if( inExpression is String )
			{
				try
				{
					new XPathParser().parseXPath( ( inExpression as String ) );
					return true;
				}
				catch( e : Error )
				{
					return false;
				}
			}
			return false;
		}

		/**
		 * @private
		 */
		override public function get priority() : int
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
		 * @private
		 */
		override public function get supportedDataTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( XML );
			return out;
		}

		/**
		 * @private
		 */
		override public function get supportedExpressionTypes() : Vector.<Class>
		{
			var out : Vector.<Class> = new Vector.<Class>();
			out.push( String );
			return out;
		}

		/**
		 * evaluates the inExpression String expression (an XPath expression) on
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
		override public function transform( inData : Object, inExpression : Object, inTarget : Object = null ) : Object
		{
			if( !( inData is XML ) )
				throw new Error( "Data is not XML" );
			return XPathQuery.execQuery( inData as XML, inExpression as String );
		}
	}
}
