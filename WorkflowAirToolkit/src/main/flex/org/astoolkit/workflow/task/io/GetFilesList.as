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
package org.astoolkit.workflow.task.io
{
	import org.astoolkit.workflow.core.BaseTask;
	
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.collections.ArrayCollection;
	
	public class GetFilesList extends BaseTask
	{
		[InjectPipeline]
		public var location : String;
		private static const EXTENSION_METHOD : String = "extension";
		private static const REGEXP_METHOD : String = "regexp";
		
		public var fileFilter : Array;
		[Inspectable(enumeration="extension,regexp", defaultValue="extension")]
		public var fileFilterMethod : String;
		public var simpleArrayOutput : Boolean;
		public var recursive : Boolean;
		private var regexps : Vector.<RegExp>;
		public var ignoreCase : Boolean = true;
		
		override public function initialize():void
		{
			super.initialize();
			regexps = new Vector.<RegExp>();
			var re : RegExp;
			for each( var f : Object in fileFilter )
			{
				if( f is RegExp )
				{
					re = RegExp( f );
				}
				else if( f is String )
				{
					if( fileFilterMethod == REGEXP_METHOD )
						re = new RegExp( f );
					else
						re = new RegExp( "\\." + f + "$" );
				}
				else
					throw new Error( "file filters can only be either type String or RegExp" );
				var extensions : String = re.toString().match( /\/\w*$/ );
				if( ignoreCase && !re.ignoreCase )
					re = new RegExp( re.source, extensions + "i" );
				else if( !ignoreCase && re.ignoreCase )
				{
					re = new RegExp( re.source, extensions.replace( /i/, "" ) );
				}
				
				regexps.push( re );
			}
		}
		
		
		override public function begin() : void
		{
			super.begin();
			var aLocation : String = location;
			if( !aLocation )
			{
				aLocation = filteredInput as String;
				if( !aLocation )
				{
					fail( "No location provided either explicitly or via the pipeline" );
					return;
				}
			}
			var files : Array;
			try
			{
				var file : File = new File( aLocation );
				if( file.isDirectory )
				{
					files = listDirectory( file, recursive ); 
					var out : *;
					if( simpleArrayOutput )
						out = files;
					else
						out = new ArrayCollection( files );
				}
				complete( out );
			}
			catch( e : Error ) 
			{
				fail( "Error reading files from location '" + aLocation + " \n\n" + e.getStackTrace() );
			}
		}
		
		private function listDirectory( inDir : File, inRecursive : Boolean = false ) : Array 
		{
			var out : Array;
			if( fileFilter )
			{
				out = inDir.getDirectoryListing().filter( 
					function callback( inFile : File, inIndex : int, inArray : Array ) : Boolean
					{
						for each( var re : RegExp in regexps )
						{
							if( inFile.name.match( re ) )
								return true;
						}
						return false;
					} );
			}
			
			if( recursive )
			{
				for each( var file : File in inDir.getDirectoryListing() )
				{
					if( file.isDirectory )
						out = out.concat( listDirectory( file, true ) );
				}
			}
			return out;
		}
	}
}