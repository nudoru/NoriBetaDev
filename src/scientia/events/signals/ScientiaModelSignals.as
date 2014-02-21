package scientia.events.signals
{
	import org.osflash.signals.Signal;
	/**
	 * @author Matt Perkins
	 */
	public class ScientiaModelSignals
	{
		
		public static const SCREEN_CHANGE:Signal = new Signal(String);
		public static const SCREEN_STATUS_CHANGE:Signal = new Signal(String);
		
	}
}
