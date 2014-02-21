package com.nudoru.nori.events
{
	import flash.events.Event;
	
	/**
	 * Dispatched when there is progress to show from the loading progress
	 */
	public class InitProgressEvent extends Event 
	{
		
		/**
		 * Progress event
		 */
		public static var EVENT_PROGRESS:String = "progress";
		
		/**
		 * Progress of the event
		 */
		public var percentage:Number;
		
		/**
		 * Contructor
		 * @param	type
		 * @param	pct
		 * @param	bubbles
		 * @param	cancelable
		 */
		public function InitProgressEvent(type:String, pct:int, bubbles:Boolean=true, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
			percentage = pct;
		} 
		
		/**
		 * Cone the event
		 * @return	a clone of the event
		 */
		public override function clone():Event 
		{ 
			return new InitProgressEvent(type, percentage, bubbles, cancelable);
		} 
		
		/**
		 * Format the event to a string
		 * @return	String representation of the event
		 */
		public override function toString():String 
		{ 
			return formatToString("InitProgressEvent", "type", "percentage", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}