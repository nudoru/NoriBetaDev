package com.nudoru.constants {
	
	/*
	* This is a catch all class to standardize various status, props and types
	*/
	public class ObjectStatus {
		
		// for misc items
		public static const NOT_INIT		:int = -1;
		public static const INIT			:int = 1;
		
		// for nodes/pages, items
		public static const NOT_ATTEMPTED	:int = 0;
		public static const INCOMPLETE		:int = 1;
		public static const COMPLETED		:int = 2;
		public static const PASSED			:int = 3;
		public static const FAILED			:int = 4;

		public function ObjectStatus():void {
			//
		}
		
	}
	
}