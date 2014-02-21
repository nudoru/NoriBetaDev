package com.nudoru.nori.events.signals
{
	import org.osflash.signals.Signal;
	
	/**
	 * Globally available signals for errors
	 * @author Matt Perkins
	 */
	public class ErrorSignals
	{
		public static var ERROR_TYPE_FATAL		:String = "error_type_fatal";
		public static var ERROR_TYPE_ERROR		:String = "error_type_error";
		public static var ERROR_TYPE_WARNING	:String = "error_type_warning";
		
		public static var ERROR_FATAL		:Signal = new Signal(Object);
		public static var ERROR_ERROR		:Signal = new Signal(Object);
		public static var ERROR_WARNING		:Signal = new Signal(Object);
	}
}
