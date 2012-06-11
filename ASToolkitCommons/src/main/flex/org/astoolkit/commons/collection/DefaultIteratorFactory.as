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
package org.astoolkit.commons.collection
{
	
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import org.astoolkit.commons.collection.annotation.IteratorSource;
	import org.astoolkit.commons.collection.api.IIterator;
	import org.astoolkit.commons.collection.api.IIteratorFactory;
	import org.astoolkit.commons.factory.PooledFactory;
	import org.astoolkit.commons.reflection.ClassInfo;
	import org.astoolkit.commons.reflection.IAnnotation;
	import org.astoolkit.commons.reflection.Metadata;
	
	public class DefaultIteratorFactory extends PooledFactory implements IIteratorFactory
	{
		private static var _iteratorsMetaCache : Object = {};
		
		private static function getIteratorSourceTypes( inObject : Object ) : Vector.<Class>
		{
			var z : String = getQualifiedClassName( Array );
			var cName : String = getQualifiedClassName( inObject )
			
			if(!_iteratorsMetaCache.hasOwnProperty( cName ))
				_iteratorsMetaCache[cName] = {};
			
			if(!_iteratorsMetaCache[cName].hasOwnProperty( "IteratorSource" ))
			{
				var ci : ClassInfo = ClassInfo.forType( inObject );
				var annotation : IteratorSource;
				var annotations : Vector.<IAnnotation> = ci.getAnnotationsOfType( IteratorSource );
				
				if(annotations && annotations.length > 0)
				{
					annotation = annotations[0] as IteratorSource;
					_iteratorsMetaCache[cName]["IteratorSource"] = annotation.types;
				}
			}
			return _iteratorsMetaCache[cName]["IteratorSource"] as Vector.<Class>;
		}
		
		public function DefaultIteratorFactory()
		{
			super();
			_registeredIteratorClasses = new Vector.<Class>();
			_registeredIteratorClasses.push( ListIterator );
			_registeredIteratorClasses.push( CountIterator );
			_registeredIteratorClasses.push( ByteArrayIterator );
			_registeredIteratorClasses.push( InfiniteIterator );
			_registeredIteratorClasses.push( FileStreamIterator );
		}
		
		private var _registeredIteratorClasses : Vector.<Class>;
		
		public function iteratorForSource( inSource : Object, inProperties : Object = null ) : IIterator
		{
			for each(var iteratorType : Class in _registeredIteratorClasses)
			{
				for each(var supportedType : Class in getIteratorSourceTypes( iteratorType ))
				{
					if((inSource == null && supportedType == null) || (supportedType != null && inSource is supportedType))
						return getInstance( iteratorType, inProperties );
				}
			}
			return null;
		}
	}
}
