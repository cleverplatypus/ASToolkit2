package org.astoolkit.commons.io.transform
{

	import org.astoolkit.commons.io.transform.api.IIODataTransformer;

	public final class REConfig
	{

		public static function create( inRegExp : RegExp, inOutputIndex : int = -1 ) : REConfig
		{
			return inRegExp ?
				new REConfig( new SingletonEnforcer(), inRegExp, inOutputIndex ) :
				null;
		}

		public static function createTransformer( inRegExp : *, inOutputIndex : int = -1 ) : IIODataTransformer
		{
			var out : RegExpDataTransform = new RegExpDataTransform();
			out.regexp =
				inRegExp is String ?
				eval( inRegExp as String, inOutputIndex ) :
				create( inRegExp as RegExp, inOutputIndex );
			return out;
		}

		public static function eval( inExpression : String, inOutputIndex : int = -1 ) : REConfig
		{
			var re : RegExp;
			var parts : Array = inExpression.toString().match( /^\/(.+)\/(\w*)$/ );

			if( parts && parts.length > 1 )
			{
				var opts : String = parts.length == 3 ? parts[ 2 ] : "";

				try
				{
					re = new RegExp( parts[ 1 ], opts );
					return create( re, inOutputIndex );
				}
				catch( e : Error )
				{
					return null;
				}
			}
			return null;
		}

		/**
		 * @private
		 */
		public function REConfig(
			inSingletonEnforcer : SingletonEnforcer,
			inRegExp : RegExp,
			inOutputIndex : int )
		{
			if( inSingletonEnforcer == null )
				throw new Error( "REConfig cannot be instanciated " +
					"directly. Use REConfig.create( ... ) or REConfig.eval( ... ) instead." );
			_regexp = inRegExp;
			_outputIndex = inOutputIndex;
		}

		private var _outputIndex : int;

		private var _regexp : RegExp;

		public function get outputIndex() : int
		{
			return _outputIndex;
		}

		public function get regexp() : RegExp
		{
			return _regexp;
		}
	}
}

class SingletonEnforcer
{
}
