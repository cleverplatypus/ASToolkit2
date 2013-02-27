package org.astoolkit.commons.mapping
{

	import org.astoolkit.commons.io.transform.api.IIODataTransformerRegistry;

	public final class MappingConfig
	{
		public var source : Object;

		public var target : Object;

		public var mapping : Object;

		public var document : Object;

		public var transformerRegistry : IIODataTransformerRegistry;

		public var strict : Boolean;
	}
}
