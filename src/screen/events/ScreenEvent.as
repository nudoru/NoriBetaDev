package screen.events
{
	import flash.events.Event;
	
	/**
	 * Base event that must be extended by asub class
	 */
	public class ScreenEvent extends Event 
	{
		/**
		 * Generic data of the event
		 */
		public var data:*;
		
		/**
		 * Constructor 
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 */
		public function ScreenEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		/**
		 * Cone the event
		 * @return	a clone of the event
		 */
		public override function clone():Event 
		{ 
			return new ScreenEvent(type, bubbles, cancelable);
		} 
		
		/**
		 * Format the event to a string
		 * @return	String representation of the event
		 */
		public override function toString():String 
		{ 
			return formatToString("ScreenEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}