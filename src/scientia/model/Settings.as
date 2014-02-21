package scientia.model
{
	import com.nudoru.nori.events.signals.AudioSignals;
	import scientia.model.VOs.ThemeVO;
	import scientia.view.ScreenTransitionType;

	
	/**
	 * Global settings class for a Screen App 
	 * Settings are different than the configVO in that they may change over execution of the content 
	 */
	public class Settings 
	{
		
		private static var _AudioEnable			:Boolean;
		private static var _AudioVolume			:Number;
		private static var _AudioMute			:Boolean;
		private static var _Captions			:Boolean;
		private static var _ThemeColors			:Array;
		private static var _HighLightColor		:Number;
		private static var _ScreenTransition	:String;
		
		private static var _ScreenXPosition		:int;
		private static var _ScreenYPosition		:int;
		private static var _ScreenWidth			:int;
		private static var _ScreenHeight		:int;
		private static var _ScaleView			:Boolean;
		
		private static var _AssetsSWF			:String;
		private static var _AssetFonts			:Array;
		
		public function Settings():void { };
		
		public static function setDefaults(theme:ThemeVO ):void
		{
			_AudioEnable = true;
			_AudioVolume = 1;
			_AudioMute = false;
			_Captions = false;
			_ThemeColors = theme.colors;
			_HighLightColor = theme.highLightColor;
			_ScaleView = theme.scaleView;
			_ScreenTransition = ScreenTransitionType.SQUEEZE;
			
			_ScreenXPosition = 0;
			_ScreenYPosition = 50;
			_ScreenWidth = 810;
			_ScreenHeight = 485;
			
			_AssetsSWF = theme.assetsSWF;

			_AssetFonts = theme.fonts;
		}
		
		public static function get audioEnable():Boolean { return _AudioEnable; }
		public static function set audioEnable(value:Boolean):void 
		{
			_AudioEnable = value;
			if (_AudioEnable) AudioSignals.AUDIO_ENABLE.dispatch();
				else AudioSignals.AUDIO_DISABLE.dispatch();
		}
		
		public static function get audioVolume():Number { return _AudioVolume; }
		public static function set audioVolume(value:Number):void 
		{
			_AudioVolume = value;
			AudioSignals.AUDIO_VOLUME_CHANGE.dispatch();
		}
		
		public static function get audioMute():Boolean { return _AudioMute; }
		public static function set audioMute(value:Boolean):void 
		{
			_AudioMute = value;
			if (_AudioMute) AudioSignals.AUDIO_MUTE_ON.dispatch();
				else AudioSignals.AUDIO_MUTE_OFF.dispatch();
		}
		
		public static function get captions():Boolean { return _Captions; }
		public static function set captions(value:Boolean):void 
		{
			_Captions = value;
		}
		
		public static function get themeColors():Array { return _ThemeColors; }
		public static function set themeColors(value:Array):void 
		{
			_ThemeColors = value;
		}
		
		public static function get highLightColor():Number { return _HighLightColor; }
		public static function set highLightColor(value:Number):void 
		{
			_HighLightColor = value;
		}
		
		public static function get screenTransition():String { return _ScreenTransition; }
		public static function set screenTransition(value:String):void 
		{
			_ScreenTransition = value;
		}
		
		public static function get screenXPosition():int 
		{
			return _ScreenXPosition;
		}
		
		public static function get screenYPosition():int 
		{
			return _ScreenYPosition;
		}
		
		public static function get screenWidth():int 
		{
			return _ScreenWidth;
		}
		
		public static function get screenHeight():int 
		{
			return _ScreenHeight;
		}
		
		public static function get assetFonts():Array 
		{
			return _AssetFonts;
		}
		
		public static function get assetsSWF():String 
		{
			return _AssetsSWF;
		}

		public static function get scaleView():Boolean
		{
			return _ScaleView;
		}

		public static function set scaleView(scaleView:Boolean):void
		{
			_ScaleView = scaleView;
		}
	}
	
}