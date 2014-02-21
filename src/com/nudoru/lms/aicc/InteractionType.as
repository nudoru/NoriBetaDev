package com.nudoru.lms.aicc
{
	
	/**
	 * AICC Types
	 */
	public class InteractionType {
		
		public static const TRUE_FALSE		:String = "T";
		public static const CHOICE			:String = "C";
		public static const FILL_IN			:String = "F";
		// long_fill_in isn't an option for AICC so treat it like a fill_in
		public static const LONG_FILL_IN	:String = "F";
		public static const LIKERT			:String = "L";
		public static const MATCHING		:String = "M";
		public static const PERFORMANCE		:String = "P";
		public static const SEQUENCING		:String = "S";
		public static const NUMBERIC		:String = "N";
		// other isn't a type for AICC, how to handle this? does it need to be handled?
		//public static const OTHER			:String = "other";
		
		public function InteractionType():void {
			//
		}
		
	}
	
}