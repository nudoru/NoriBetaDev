package com.nudoru.nori.mvc
{
	import com.nudoru.nori.events.ICommandMap;
	import flash.events.IEventDispatcher;
	
	/**
	 * Based on the Robotlegs Actor. 
	 * Possible uses: Model, Mediators, Controllers, etc.
	 * 
	 * @author Matt Perkins
	 */
	public class Actor implements IActor
	{
		
		protected var _eventDispatcher:IEventDispatcher;
		protected var _commandMap:ICommandMap;

		public function get eventDispatcher():IEventDispatcher
		{
			return _eventDispatcher;
		}

		[Inject]
		public function set eventDispatcher(eventDispatcher:IEventDispatcher):void
		{
			_eventDispatcher = eventDispatcher;
		}

		public function get commandMap():ICommandMap
		{
			return _commandMap;
		}

		[Inject]
		public function set commandMap(value:ICommandMap):void
		{
			_commandMap = value;
		}
		
		public function Actor() 
		{
		}
		
	}
}
