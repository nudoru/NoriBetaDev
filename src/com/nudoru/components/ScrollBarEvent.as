package com.nudoru.components
{
	import flash.events.Event;
	
	/**
	 * Base event that must be extended by a sub class
	 */
	public class ScrollBarEvent extends ComponentEvent
	{
		
		public var position						:Number;
		
		public static var EVENT_SCROLL			:String = "event_scroll";
		
		/**
		 * Constructor 
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 */
		public function ScrollBarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		/**
		 * Cone the event
		 * @return	a clone of the event
		 */
		override public function clone():Event 
		{ 
			return new ScrollBarEvent(type, bubbles, cancelable);
		} 
		
		/**
		 * Format the event to a string
		 * @return	String representation of the event
		 */
		override public function toString():String 
		{ 
			return formatToString("NudoruScrollBarEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}