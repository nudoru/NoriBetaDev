package scientia.controller.commands 
{

	/**
	 * Resumes the view when the browser regains focus
	 */
	public class ResumeViewCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		public function ResumeViewCommand():void
		{
			super();
		}
		
		/**
		 * Tell the view to resume
		 */
		override public function execute():void {
			//Debugger.instance.add("ResumeViewCommand, execute");
			view.resumeRender();
		}
		
	}

}