package screen.events.signals
{
	import org.osflash.signals.Signal;
	
	/**
	 * Signals for the screen display
	 * @author Matt Perkins
	 */
	public class ScreenDisplaySignals
	{
		public static var LOADED		:Signal = new Signal();
		public static var INITIALIZED	:Signal = new Signal();
		public static var RENDERED		:Signal = new Signal();
		public static var UNLOADED		:Signal = new Signal();
	}
}
