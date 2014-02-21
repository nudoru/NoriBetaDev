package com.nudoru.components
{
	import flash.events.Event;
	
	/**
	 * Base event that must be extended by a sub class
	 */
	public class ComponentEvent extends Event 
	{
		/**
		 * Generic data of the event
		 */
		public var data:*;
		
		public static var EVENT_INITIALIZED			:String = "event_initialized";
		public static var EVENT_DESTROYED			:String = "event_destroyed";
		
		// for visual
		public static var EVENT_RENDERED			:String = "event_rendered";
		public static var EVENT_UPDATED				:String = "event_updated";
		
		// for data
		public static var EVENT_ERROR				:String = "event_error";
		public static var EVENT_PARSE_ERROR			:String = "event_parse_error";
		public static var EVENT_IOERROR				:String = "event_ioerror";
		public static var EVENT_LOADED				:String = "event_loaded";
		public static var EVENT_PROGRESS			:String = "event_progress";
		
		// for interactive
		public static var EVENT_CLICK				:String = "event_click";
		public static var EVENT_ACTIVATE			:String = "event_activate";
		public static var EVENT_DEACTIVATE			:String = "event_deactivate";
		public static var EVENT_SELECTED			:String = "event_selected";
		public static var EVENT_UNSELECTED			:String = "event_unselected";
		
		public static var EVENT_START_DRAG			:String = "event_start_drag";
		public static var EVENT_STOP_DRAG			:String = "event_stop_drag";
		
		public static var EVENT_DATA				:String = "event_data";
	
		/**
		 * Constructor 
		 * @param	type
		 * @param	bubbles
		 * @param	cancelable
		 */
		public function ComponentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		/**
		 * Cone the event
		 * @return	a clone of the event
		 */
		public override function clone():Event 
		{ 
			return new ComponentEvent(type, bubbles, cancelable);
		} 
		
		/**
		 * Format the event to a string
		 * @return	String representation of the event
		 */
		public override function toString():String 
		{ 
			return formatToString("NudoruComponentEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}