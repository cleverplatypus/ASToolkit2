package org.astoolkit.workflow.task.events
{

	import mx.collections.IList;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	import org.astoolkit.workflow.constant.UNDEFINED;
	import org.astoolkit.workflow.core.BaseTask;

	/**
	 * Completes when the <code>target</code> IList dispatches
	 * a <code>CollectionChange</code> event.
	 * <p>The <code>watch<em>BLA</em></code> flags determine
	 * what event kind will be considered.</p>
	 * <p>If no flag is set, any event kind will be considered</p>
	 * <p>
	 * <b>Any Input</b>
	 * </p>
	 * <p>
	 * <b>Output</b>
	 * <ul>
	 * <li>The target collection if <code>outputKind == "collection"</code></li>
	 * </ul>
	 * </p>
	 * <p>
	 * <b>Params</b>
	 * <ul>
	 * <li><code>target</code> (Injectable): the collection to watch</li>
	 * <li><code>watchAdd</code>: whether to complete when <code>event.kind == CollectionEventKind.ADD</code></li>
	 * <li><code>watchMove</code>: whether to complete when <code>event.kind == CollectionEventKind.MOVE</code></li>
	 * <li><code>watchRefresh</code>: whether to complete when <code>event.kind == CollectionEventKind.REFRESH</code></li>
	 * <li><code>watchRemove</code>: whether to complete when <code>event.kind == CollectionEventKind.REMOVE</code></li>
	 * <li><code>watchReplace</code>: whether to complete when <code>event.kind == CollectionEventKind.REPLACE</code></li>
	 * <li><code>watchReset</code>: whether to complete when <code>event.kind == CollectionEventKind.RESET</code></li>
	 * <li><code>watchUpdate</code>: whether to complete when <code>event.kind == CollectionEventKind.UPDATE</code></li>
	 * </ul>
	 * </p>
	 */
	public class WatchCollection extends BaseTask
	{

		[Bindable]
		[InjectPipeline]
		public var target : IList;

		public var watchAdd : Boolean;

		public var watchMove : Boolean;

		public var watchRefresh : Boolean;

		public var watchRemove : Boolean;

		public var watchReplace : Boolean;

		public var watchReset : Boolean;

		public var watchUpdate : Boolean;

		/**
		 * @private
		 */
		override public function begin() : void
		{
			super.begin();

			if( !target )
			{
				fail( "No collection provided" );
				return;
			}
			target.addEventListener(
				CollectionEvent.COLLECTION_CHANGE,
				threadSafe( onCollectionChange ) );
		}

		[Inspectable( enumeration="auto,collection" )]
		override public function set outputKind( inValue : String ) : void
		{
			super.outputKind = inValue;
		}

		/**
		 * @private
		 */
		private function onCollectionChange( inEvent : CollectionEvent ) : void
		{
			if( ( !watchAdd &&
				!watchMove &&
				!watchRefresh &&
				!watchRemove &&
				!watchReplace &&
				!watchReset &&
				!watchUpdate ) ||
				( inEvent.kind == CollectionEventKind.ADD && watchAdd ) ||
				( inEvent.kind == CollectionEventKind.MOVE && watchMove ) ||
				( inEvent.kind == CollectionEventKind.REFRESH && watchRefresh ) ||
				( inEvent.kind == CollectionEventKind.REMOVE && watchRemove ) ||
				( inEvent.kind == CollectionEventKind.REPLACE && watchReplace ) ||
				( inEvent.kind == CollectionEventKind.RESET && watchReset ) ||
				( inEvent.kind == CollectionEventKind.UPDATE && watchUpdate ) )
				complete( _outputKind == "collection" ? target : UNDEFINED );
		}
	}
}
