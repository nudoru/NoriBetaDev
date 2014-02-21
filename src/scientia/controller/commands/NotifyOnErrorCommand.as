package scientia.controller.commands 
{
	import com.nudoru.debug.Debugger;
	import com.nudoru.nori.events.signals.ErrorSignals;

	
	/**
	 * Handles the event when the the Model needs to jump to a new screen
	 */
	public class NotifyOnErrorCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		public function NotifyOnErrorCommand():void
		{
			super();
		}
		
		/**
		 * Handle command neccessary to jump to a new screen.
		 */
		override public function execute():void {
			Debugger.instance.add("OnErrorCommand, execute: " + data[0].type + " - " + data[0].message, this);
			switch(data[0].type) {
					case ErrorSignals.ERROR_TYPE_FATAL:
						view.showModalMessage("Error", data[0].message);
						break;
					case ErrorSignals.ERROR_TYPE_ERROR:
						view.showModalMessage("Fatal Error", data[0].message);
						break;
					default:
						view.showMessage("Warning", data[0].message);
			}
		}
		
	}

}