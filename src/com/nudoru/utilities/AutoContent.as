package com.nudoru.utilities {
	
	/**
	 * 
	 * @author Matt Perkins
	 */
	public class AutoContent {

		public function AutoContent():void { }
		
		public function applyContentFunction(s:String):String {
			if (s.indexOf("getlatin") == 0) {
				var l:RandomLatin = new RandomLatin();
				return l.generateLatinString(s);
			}
			return s;
		}
		
	}
	
}