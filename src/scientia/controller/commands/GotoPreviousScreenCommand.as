package scientia.controller.commands 
{

	/**
	 * Handles the event when the the Model needs to jump to a new screen
	 */
	public class GotoPreviousScreenCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		public function GotoPreviousScreenCommand():void
		{
			super();
		}
		
		/**
		 * Handle command neccessary to jump to a new screen.
		 */
		override public function execute():void {
			//Debugger.instance.add("GotoPreviousScreenCommand, execute, to screen", this);
			model.gotoPreviousScreen();
		}
		
	}

}