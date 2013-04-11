package org.astoolkit.test.autoassign
{

	import org.astoolkit.commons.configuration.api.ISelfWiring;
	import org.astoolkit.commons.wfml.autoassign.AutoAssignUtil;
	import org.astoolkit.commons.wfml.autoassign.PropertyDataBuilderInfo;

	[DefaultProperty( "selfWiringChildren" )]
	[Exclude( kind="property", name="selfWiringChildren" )]
	public class BaseSelfWiringDocument implements ISelfWiring
	{


		private var _selfWiringChildren : Array;

		public function set selfWiringChildren(inValue:Array) : void
		{
			_selfWiringChildren = inValue;
		}

		public function get selfWiringChildren() : Array
		{
			return _selfWiringChildren;
		}

		public function build() : void
		{
			var buildersInfo : Vector.<PropertyDataBuilderInfo> =
				AutoAssignUtil.autoAssign( this, _selfWiringChildren );

			AutoAssignUtil.processDataBuilders( this, buildersInfo );
		}

		[AutoAssign]
		public var genericObject : Object;

		[AutoAssign( order="1" )]
		public var builtString : String;

		[AutoAssign]
		public var mappedWithPid : Object;

		public function initialized(document:Object, id:String) : void
		{
			// TODO Auto Generated method stub

		}


		[AutoAssign( order="2" )]
		public var secondaryString : String;

		[AutoAssign( match="Class" )]
		[AutoAssign( match="mx.core.IFactory" )]
		public var classOrFactory : Object;
	}
}
