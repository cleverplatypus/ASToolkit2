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
package org.astoolkit.workflow.flex4.task.spark
{

	import mx.effects.Effect;
	import mx.events.EffectEvent;
	import org.astoolkit.workflow.core.BaseTask;
	import spark.effects.Animate;

	/**
	 * Plays a Spark <code>Effect</code>
	 * <p>If <code>blocking</code> is set to true the task waits
	 * for the effect to finish before calling <code>complete()</code>.
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>blocking</code>: whether to complete asynchronously</li>
	 * </ul>
	 * </p>
   *
			  * @example Animating a property.
	 * 			<p>In the following snippet we're playing an <code>Animate</code> effect
	 * 			and waiting for it to finish to complete the task.</p>
	 * <listing version="3.0">
	 * <pre>
	 * &lt;spark:PlaySparkAnimation
	 *     blocking=&quot;true&quot;&gt;
	 *     &lt;s:Animate
	 *         duration=&quot;1000&quot;
	 *         target=&quot;{ myTarget }&quot;
	 *         &gt;
	 *         &lt;s:SimpleMotionPath
	 *             property=&quot;myAnimatedProperty&quot;
	 *             valueFrom=&quot;0&quot;
	 *             valueTo=&quot;100&quot;
	 *             /&gt;
	 *     &lt;/s:Animate&gt;
	 * &lt;/spark:PlaySparkAnimation&gt;
	 * </pre>
	 * </listing>
	 */
	public class PlaySparkAnimation extends BaseTask
	{
		[AutoAssign]
		/**
		 * the animation to play (default property)
		 */
		public var animation : Effect;

		/**
		 * if <code>true</code> the task will complete after the effect completes,
		 * otherwise it will start the effect and complete synchronously.
		 */
		public var blocking : Boolean = true;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !animation )
			{
				fail( "No animation set." );
				return;
			}

			if( animation.target == null )
				animation.target = filteredInput;
			animation.play();

			if( blocking )
			{
				animation.addEventListener( EffectEvent.EFFECT_END, threadSafe( onAnimationEnd ) );
			}
			else
				complete();
		}

		/**
		 * @private
		 */
		private function onAnimationEnd( inEvent : EffectEvent ) : void
		{
			complete();
		}
	}
}
