package org.astoolkit.commons.io.transform
{

	import flash.utils.getQualifiedClassName;
	import org.astoolkit.commons.io.transform.api.IIODataTransformer;

	public class BaseDataTransformer implements IIODataTransformer
	{

		public function BaseDataTransformer()
		{
			if( getQualifiedClassName( this ) == getQualifiedClassName( BaseDataTransformer ) )
				throw new Error( "BaseDataTransformer is abstract" );
		}

		protected var _next : IIODataTransformer;

		protected var _parent : IIODataTransformer;

		public function set next(value:IIODataTransformer):void
		{
			_next = value;
		}

		public function chain( inNext : IIODataTransformer ) : IIODataTransformer
		{
			inNext.parent = this;
			return _next = inNext;
		}

		public function isValidExpression( inExpression : Object ) : Boolean
		{
			return false;
		}

		public function get next() : IIODataTransformer
		{
			return _next;
		}

		public function get parent() : IIODataTransformer
		{
			return _parent;
		}

		public function set parent( value : IIODataTransformer ) : void
		{
			_parent = value;
		}

		public function get priority() : int
		{
			return -1;
		}

		public function root() : IIODataTransformer
		{
			var trans : IIODataTransformer = this;

			while( trans.parent )
				trans = trans.parent
			return parent;
		}

		public function get supportedDataTypes() : Vector.<Class>
		{
			return null;
		}

		public function get supportedExpressionTypes() : Vector.<Class>
		{
			return null;
		}

		public function transform( inData : Object, inExpression : Object, inTarget : Object = null ) : Object
		{
			throw new Error( "BaseDataTransformer is abstract" );
			return null;
		}
	}
}
