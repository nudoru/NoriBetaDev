package scientia.controller.commands
{
	import scientia.utils.ILMSUpdater;

	/**
	 * Checks for course completion and saves completion data
	 * 
	 * @author Matt Perkins
	 */
	public class UpdateOnScreenStatusChangeCommand extends AbstractScientiaCommand
	{
		
		private var _lmsUpdater:ILMSUpdater;
		
		public function get lmsUpdater():ILMSUpdater
		{
			return _lmsUpdater;
		}

		[Inject]
		public function set lmsUpdater(value:ILMSUpdater):void
		{
			_lmsUpdater = value;
		}
		
		public function UpdateOnScreenStatusChangeCommand()
		{
			super();
		}
		
		override public function execute():void 
		{
			lmsUpdater.update();
			
			updateNavigationOnScreenStatus();
		}
		
		private function updateNavigationOnScreenStatus():void
		{
			if(model.getCurrentScreen().scored && !model.getCurrentScreen().isComplete())
			{
				 view.disableNextButton();
			}
			else
			{
				if (model.structureVO.isLinearNextScreen()) view.enableNextButton();
			}
		}
		
	}
}
