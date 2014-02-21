package com.nudoru.sheet {
	
	import flash.events.*;
	
	public class SheetSettings extends EventDispatcher {
		
		static private var _Instance	:SheetSettings;
		
		private var _ThemeColors		:Array;
		private var _ThemeHiColor		:Number;
		private var _ThemeHiStyle		:String;
	
		private var _ImageCaptionFont	:String;
		
		public function get themeColors():Array { 
			return _ThemeColors;
		}
		public function get themeHiColor():Number { 
			return _ThemeHiColor;
		}
		public function get themeHiStyle():String {
			return _ThemeHiStyle;
		}
		
		public function get imageCaptionFont():String { 
			return _ImageCaptionFont;
		}

		public function SheetSettings(singletonEnforcer:SingletonEnforcer) {}
		
		public static function get instance():SheetSettings {
			if (SheetSettings._Instance == null) {
				SheetSettings._Instance = new SheetSettings(new SingletonEnforcer());
				SheetSettings._Instance.setDefaults();
			}
			return SheetSettings._Instance;
		}

		public function setDefaults():void {
			_ImageCaptionFont = "Verdana";
			
			_ThemeColors = [];
			_ThemeHiColor = 0x00ff00;
			_ThemeHiStyle = "rounded:10";
		}
		
	}
}

class SingletonEnforcer {}