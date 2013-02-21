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
package org.astoolkit.workflow.api
{

	//TODO: check livecycle of plug-ins. it looks like certain extensions should
	//		have a context scope rather than context-factory scope. That is
	//		if an extension has state, then it should be instanciated using a factory
	//		rather than by direct instanciation. Or: 
	//		function get statefulExtensions() : Array;
	public interface IContextPlugIn
	{
		function getConfigExtensions() : Array;
		function getStatefulExtensions() : Array;
		function getInitialStateData( inContext : IWorkflowContext ) : Object;
	}
}
