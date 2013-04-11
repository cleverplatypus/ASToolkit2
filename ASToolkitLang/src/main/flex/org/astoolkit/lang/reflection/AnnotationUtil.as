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
package org.astoolkit.lang.reflection
{

	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import org.astoolkit.lang.reflection.api.IAnnotation;

	public final class AnnotationUtil
	{
		private static var _annotations : Object = {};

		private static var _annotationsByAnnotationType : Object = {};

		private static var _cache : Object = {};

		private static var _classes : Object = {};

		public static function getAnnotationsFromMetadata( inMetadata : XMLList ) : Vector.<IAnnotation>
		{
			var out : Vector.<IAnnotation> = new Vector.<IAnnotation>();
			var annotation : IAnnotation;

			for each( var metaNode : XML in inMetadata )
			{
				if( _annotations.hasOwnProperty( metaNode.@name.toString() ) )
				{
					var factory : IFactory = _annotations[ metaNode.@name.toString() ] as IFactory;
					annotation = factory.newInstance();
				}
				else
				{
					annotation = new Metadata();
				}
				annotation.initialize( metaNode );
				out.push( annotation );
			}
			return out;
		}

		public static function registerAnnotation( inFactory : IFactory ) : void
		{
			var instance : Metadata = inFactory.newInstance() as Metadata;
			var classInfo : XML = describeType( instance );
			_annotations[ instance.tagName ] = inFactory;
			_annotationsByAnnotationType[ getQualifiedClassName( instance ) ] = inFactory;
		}
	}
}
