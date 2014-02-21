package scientia.controller.commands.startup 
{
	import com.nudoru.debug.Debugger;
	import scientia.controller.commands.AbstractScientiaCommand;
	import scientia.controller.commands.IAbstractScientiaCommand;
	import scientia.events.signals.StartupSignals;

	/**
	 * Handles the event when the the Model needs to jump to a new screen
	 */
	public class StartupCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		public function StartupCommand():void
		{
			super();
		}
		
		/**
		 * Handle command neccessary to jump to a new screen.
		 */
		override public function execute():void {
			Debugger.instance.add("StartupCommand", this);
			
			view.render();
			view.setTitle(model.configVO.name);

			if(model.configVO.lmsMode) StartupSignals.INITIALIZE_LMS.dispatch();
				else StartupSignals.START_UP_NO_LMS.dispatch();
		}
		
	}

}