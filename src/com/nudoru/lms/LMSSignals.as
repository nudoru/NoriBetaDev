package com.nudoru.lms
{
	import org.osflash.signals.Signal;
	
	/**
	 * LMS status Signals
	 */
	public class LMSSignals
	{
		
		public static const INITIALIZED				:Signal = new Signal();
		public static const NOT_INITIALIZED			:Signal = new Signal();
		public static const CANNOT_CONNECT			:Signal = new Signal();
		public static const CONNECTION_LOST			:Signal = new Signal();
		public static const ERROR					:Signal = new Signal(String);
		public static const SUCCESS					:Signal = new Signal(String);
		public static const CANNOT_CLOSE_WINDOW		:Signal = new Signal();
		public static const UPDATE					:Signal = new Signal();
		
		public static const COMMIT					:Signal = new Signal();
		public static const SET_SCORE				:Signal = new Signal(int);
		public static const SET_STATUS				:Signal = new Signal(int);
		public static const SET_INCOMPLETE			:Signal = new Signal();
		public static const SET_COMPLETE			:Signal = new Signal();
		public static const SET_PASS				:Signal = new Signal();
		public static const SET_FAIL				:Signal = new Signal();
		public static const SET_LASTLOCATION		:Signal = new Signal(String);
		public static const SET_SUSPENDDATA			:Signal = new Signal(String);
		public static const EXIT					:Signal = new Signal();

		
	}
	
}