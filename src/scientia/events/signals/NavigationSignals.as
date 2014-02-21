  package scientia.events.signals
{
	import org.osflash.signals.Signal;
	
	/**
	 * Globally available signals pertaining to navigation
	 * @author Matt Perkins
	 */
	public class NavigationSignals
	{
		public static var GOTO_URL				:Signal = new Signal(String);
		public static var GOTO_SCREEN_ID		:Signal = new Signal(String);
		public static var GOTO_NEXT_SCREEN		:Signal = new Signal();
		public static var GOTO_PREVIOUS_SCREEN	:Signal = new Signal();
		
		public static var MAIN_MENU_SELECTION	:Signal = new Signal();
		public static var PAGE_MENU_SELECTION	:Signal = new Signal();

		public static var REFRESH_CURRENT_SCREEN:Signal = new Signal();
		
		public static var EXIT					:Signal = new Signal();
		public static var SHOW_EXIT_PROMPT		:Signal = new Signal();
	}
}
