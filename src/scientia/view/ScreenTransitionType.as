
package scientia.view {
	public class ScreenTransitionType {
		
		public static const NONE			:String = "none";
		public static const SLIDE			:String = "slide";
		public static const SQUEEZE			:String = "squeeze";
		public static const XFADE_QUICK		:String = "xfade_quick";
		public static const XFADE_SLOW		:String = "xfade_slow";

		public static const DUR_QUICK		:Number = .25;
		public static const DUR_MEDIUM		:Number = .5;
		public static const DUR_SLOW		:Number = 1;
		
		public static const DIR_BACK		:int = -1;
		public static const DIR_NONE		:int = 0;
		public static const DIR_NEXT		:int = 1;
		
		public static const TYPE_ANIM		:String = "anim_";
		public static const TYPE_PROG		:String = "prog_";
		
		public static const SCREEN_TRANS_STATIC:String = "screen_transition_static";
		public static const SCREEN_TRANS_ANIM	:String = "screen_transition_animation";
		public static const SCREEN_TRANS_PROG	:String = "screen_transition_progamatic";
		
		public function ScreenTransitionType():void {
			//
		}

	}
	
}