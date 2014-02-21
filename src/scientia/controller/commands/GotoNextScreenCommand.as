package scientia.controller.commands 
{

	/**
	 * Handles the event when the the Model needs to jump to a new screen
	 */
	public class GotoNextScreenCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		public function GotoNextScreenCommand():void
		{
			super();
		}
		
		/**
		 * Handle command neccessary to jump to a new screen.
		 */
		override public function execute():void {
			//Debugger.instance.add("GotoNextScreenCommand, execute, to screen", this);
			model.gotoNextScreen();
		}
		
	}

}