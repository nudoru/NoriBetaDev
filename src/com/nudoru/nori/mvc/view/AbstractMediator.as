package com.nudoru.nori.mvc.view
{
	import com.nudoru.nori.mvc.Actor;
	import flash.events.Event;

	/**
	 * @author Matt Perkins
	 */
	public class AbstractMediator extends Actor implements IAbstractMediator
	{
		/**
		 * View component the mediator manages
		 */
		protected var _viewComponent			:Object;

		public function get viewComponent():Object
		{
			return _viewComponent;
		}

		public function set viewComponent(viewComponent:Object):void
		{
			_viewComponent = viewComponent;
		}
		
		/**
		 * Constructor
		 */
		public function AbstractMediator():void
		{
		}
		
		/**
		 * Initialize the mediator
		 */
		[PostConstruct]
		public function initialize():void
		{
			registerViewEvents();
			onRegister();
		}
		
		/**
		 * Startup hook to the mediator
		 */
		public function onRegister():void
		{
			trace("NEED TO OVERRIDE ABSTRACTMEDIATOR ONREGISTER FUNCTION");
		}
		
		/**
		 * Assign events to the view
		 */
		protected function registerViewEvents():void
		{
			_viewComponent.addEventListener(Event.ADDED_TO_STAGE, onViewAddedToStage, false, 0, true);
			_viewComponent.addEventListener(Event.REMOVED_FROM_STAGE, onViewRemovedFromStage, false, 0, true);
		}
		
		/**
		 * Remove events from the view
		 */
		protected function unRegisterViewEvents():void
		{
			_viewComponent.removeEventListener(Event.ADDED_TO_STAGE, onViewAddedToStage);
			_viewComponent.removeEventListener(Event.REMOVED_FROM_STAGE, onViewRemovedFromStage);
		}
		
		/**
		 * Handler for the view added to the stage
		 */
		protected function onViewAddedToStage(event:Event):void
		{
			//
		}
		
		/**
		 * Handler for the view removed from the stage
		 */
		protected function onViewRemovedFromStage(event:Event):void
		{
			destroy();
		}
		
		/**
		 * Unregister events and destroy
		 */
		public function destroy():void
		{
			unRegisterViewEvents();
			
			_viewComponent = null;
		}

	}
}
