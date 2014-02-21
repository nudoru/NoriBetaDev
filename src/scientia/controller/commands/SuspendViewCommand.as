package scientia.controller.commands 
{

	/**
	 * Suspends the view when the browser looses focus
	 */
	public class SuspendViewCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		public function SuspendViewCommand():void
		{
			super();
		}
		
		/**
		 * Tell the view to suspend
		 */
		override public function execute():void {
			//Debugger.instance.add("SuspendViewCommand, execute");
			view.suspendRender();
		}
		
	}

}