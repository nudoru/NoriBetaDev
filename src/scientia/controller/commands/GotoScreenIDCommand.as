package scientia.controller.commands 
{

	/**
	 * Handles the event when the the Model needs to jump to a new screen
	 */
	public class GotoScreenIDCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		public function GotoScreenIDCommand():void
		{
			super();
		}
		
		/**
		 * Handle command neccessary to jump to a new screen.
		 */
		override public function execute():void {
			//Debugger.instance.add("GoToScreenCommand, execute, to screen: "+data[0], this);
			model.gotoScreenID(data[0]);
		}
		
	}

}