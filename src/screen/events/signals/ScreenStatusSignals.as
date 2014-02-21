package screen.events.signals
{
	import com.nudoru.lms.scorm.InteractionObject;
	import org.osflash.signals.Signal;
	
	/**
	 * Signals for the screen status
	 * @author Matt Perkins
	 */
	public class ScreenStatusSignals
	{
		public static var INCOMPLETE	:Signal = new Signal();
		public static var COMPLETED		:Signal = new Signal(InteractionObject);
		public static var PASSED		:Signal = new Signal(InteractionObject);
		public static var FAILED		:Signal = new Signal(InteractionObject);
	}
}
