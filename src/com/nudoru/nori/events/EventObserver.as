package com.nudoru.nori.events
{
	import flash.events.Event;

	/**
	 * Modification of Omar Gonzalez's SignalObserver class to support Events
	 * 
	 * @author Omar Gonzalez
	 * @author Matt Perkins
	 */
	public class EventObserver
	{
		private var _notify:Function;
		private var _context:ICommandMap;
		private var _eventType:String;

		/**
		 * @Constructor
		 * 
		 * @param eventtype Event type to watch for.
		 * @param notifyMethod Function callback to notify/invoke.
		 * @param notifyContext Object on which the function callback exists.
		 */
		public function EventObserver(eventtype:String, notifyMethod:Function, notifyContext:ICommandMap)
		{
			_eventType = eventtype;
			_notify = notifyMethod;
			_context = notifyContext;

			_context.addEventListener(_eventType, _eventWatcher, false, 0, true);
		}

		/**
		 * The method that watches for dispatches from the signal, notifies the observers.
		 * 
		 * @param event
		 */
		private function _eventWatcher(event:Event):void
		{
			_eventObservers(event);
		}

		/**
		 * Sends the signal to all observers of this Event object dispatches.
		 * 
		 * @param event
		 */
		private function _eventObservers(event:Event):void
		{
			_notify(event);
		}

		/**
		 * Destroys the EventObserver object.
		 */
		public function destroy():void
		{
			if (_eventType)
			{
				_context.removeEventListener(_eventType, _eventWatcher);
			}

			_context = null;
			_notify = null;
			_eventType = null;
		}
	}
}
