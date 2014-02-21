package scientia.events.signals
{
	import org.osflash.signals.Signal;

	/**
	 * @author Matt Perkins
	 */
	public class StartupSignals
	{
		public static const START_UP:Signal = new Signal();
		public static const INITIALIZE_LMS:Signal = new Signal();
		public static const START_UP_LMS:Signal = new Signal();
		public static const START_UP_NO_LMS:Signal = new Signal();
	}
}
