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
package org.astoolkit.commons.conditional
{

	import flash.utils.getQualifiedClassName;
	
	import org.astoolkit.commons.conditional.api.IConditionalExpression;
	import org.astoolkit.commons.conditional.api.IConditionalExpressionGroup;
	import org.astoolkit.commons.conditional.api.IExpressionResolver;
	import org.astoolkit.commons.io.transform.api.IIODataSourceClient;
	import org.astoolkit.commons.io.transform.api.IIODataSourceResolverDelegate;
	import org.astoolkit.commons.io.transform.api.IIODataTransformer;
	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;
	import org.astoolkit.commons.utils.IChildrenAwareDocument;

	public class BaseConditionalExpression implements IConditionalExpression, IIODataSourceClient
	{
		protected var _lastResult : *;

		protected var _negate : Boolean;
		
		protected var _parent : IConditionalExpressionGroup;

		protected var _resolver : IExpressionResolver;

		protected var _dataTransformerRegistry : IIODataTransformerRegistry;
		
		protected var _inputFilter : Object;
		
		protected var _source : Object;
		
		protected var _sourceResolverDelegate : IIODataSourceResolverDelegate;
		
		protected var _delegate : Function;

		public function set delegate(value:Function):void
		{
			_delegate = value;
		}
		
		public function get async() : Boolean
		{
			return false;
		}

		public function set negate( inValue : Boolean ) : void
		{
			_negate = inValue;
		}
		
		public function clearResult() : void
		{
			_lastResult = undefined;

		}

		protected function getFilteredInput( inData : Object ) : *
		{
			if( _inputFilter != null && _dataTransformerRegistry == null )
				throw new Error( "No data transformer registry available" );
			if( _inputFilter )
			{
				var filter : IIODataTransformer =
					_inputFilter is IIODataTransformer ?
					_inputFilter as IIODataTransformer :
					_dataTransformerRegistry.getTransformer( inData, _inputFilter );
				
				if( !filter )
				{
					var filterData : String = _inputFilter is String ?
						"\"" + _inputFilter + "\"" : getQualifiedClassName( _inputFilter );
					
					throw new Error( "Error filtering input data" );
				}
				var data : Object = inData;
				
				while( filter )
				{
					data = filter.transform(
						data,
						_inputFilter is IIODataTransformer ? null : _inputFilter,
						this );
					filter = filter.next;
				}
				return data;
			}
			return inData;
		}
		
		protected function resolveSource( inInputData : Object ) : *
		{
			if( _source != null && _sourceResolverDelegate == null )
			{
				throw new Error( "No data source resolver for source=\"" + _source + "\"");
			}
			
			if( _source != null )
				return getFilteredInput( _sourceResolverDelegate.resolveDataSource( _source, null ) );
			else
				return getFilteredInput( inInputData );
		}
		
		public function evaluate( inComparisonValue : * = undefined ) : Object
		{
			return undefined;
		}
		
		public function set dataTransformerRegistry(inRegistry:IIODataTransformerRegistry):void
		{
			_dataTransformerRegistry = inRegistry;
		}
		
		public function set inputFilter( inValue : Object ) : void
		{
			_inputFilter = inValue;
		}
		
		
		public function initialized( inDocument : Object, inId : String ) : void
		{
			if( inDocument is IChildrenAwareDocument )
				IChildrenAwareDocument( inDocument ).childNodeAdded( this );
		}


		public function invalidate() : void
		{
			_lastResult = undefined;
		}

		public function get lastResult() : *
		{
			return _lastResult;
		}


		public function get parent() : IConditionalExpressionGroup
		{
			return _parent;
		}

		public function set parent( value : IConditionalExpressionGroup ) : void
		{
			_parent = value;
		}

		public function set resolver( inValue : IExpressionResolver ) : void
		{
			_resolver = inValue;
		}

		public function get root() : IConditionalExpressionGroup
		{
			var exp : IConditionalExpression = this;

			while( exp.parent )
				exp = exp.parent;
			return exp as IConditionalExpressionGroup;
		}
		
		public function set source( inValue : Object ) : void
		{
			_source = inValue
		}
		
		public function set sourceResolverDelegate( inValue : IIODataSourceResolverDelegate ) : void
		{
			_sourceResolverDelegate = inValue;
			
		}
		
		protected function negateSafeResult( inValue : Boolean ) : Boolean
		{
			return inValue && !_negate || !inValue && _negate;
		}
		

	}
}

