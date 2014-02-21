package com.nudoru.nori.mvc.view
{
	import flash.events.IEventDispatcher;
	import com.nudoru.nori.events.signals.AbstractViewSignals;
	import flash.display.Sprite;
	import flash.events.Event;
	import org.osflash.signals.natives.NativeSignal;

	/**
	 * Basic View with integration to the Nori framework.
	 * Commands are called when the view is added or removed from the stage to
	 * 	"auto-wire" (inject) and automatically assign any registered mediators
	 */
	public class AbstractNoriView extends Sprite implements IAbstractNoriView
	{
		public var autoWire						:Boolean = true;

		protected var _addedToStageSignal		:NativeSignal;
		protected var _removedFromStageSignal	:NativeSignal;

		/**
		 * Context Event dispatcher
		 */
		protected var _eventDispatcher			:IEventDispatcher;

		public function get addedToStageSignal():NativeSignal
		{
			return _addedToStageSignal;
		}

		public function get removedFromStageSignal():NativeSignal
		{
			return _removedFromStageSignal;
		}

		public function get eventDispatcher():IEventDispatcher
		{
			return _eventDispatcher;
		}

		[Inject]
		public function set eventDispatcher(eventDispatcher:IEventDispatcher):void
		{
			_eventDispatcher = eventDispatcher;
		}

		/**
		 * Constructor
		 */
		public function AbstractNoriView():void
		{
			// set up singnals
			_addedToStageSignal = new NativeSignal(this, Event.ADDED_TO_STAGE, Event);
			_removedFromStageSignal = new NativeSignal(this, Event.REMOVED_FROM_STAGE, Event);

			_addedToStageSignal.add(onAddedToStage);
			_removedFromStageSignal.add(onRemovedFromStage);
		}

		protected function onAddedToStage(event:Event):void
		{
			AbstractViewSignals.ADDED_TO_STAGE.dispatch(this);
		}

		protected function onRemovedFromStage(event:Event):void
		{
			AbstractViewSignals.REMOVED_FROM_STAGE.dispatch(this);
		}

		/**
		 * Initialize the view
		 */
		[PostConstruct]
		public function initialize(data:*=null):void
		{
		}

		/**
		 * Draw the view
		 */
		public function render():void
		{
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		public function destroy():void
		{
			_addedToStageSignal.remove(onAddedToStage);
			_removedFromStageSignal.remove(onRemovedFromStage);
		}

	}
}