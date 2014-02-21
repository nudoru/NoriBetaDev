package com.nudoru.lms.aicc
{
	
	/**
	 * AICC types
	 */
	public class InteractionResult {
		
		public static const CORRECT			:String = "C";
		// incorrect is "wrong" in AICC, but keep incorrect for consistancy with SCORM
		public static const INCORRECT		:String = "W";
		public static const UNANTICIPATED	:String = "U";
		public static const NEUTRAL			:String = "N";

		public function InteractionResult():void {
			//
		}
		
	}
	
}