package scientia.controller.commands
{
	import scientia.utils.ILMSUpdater;

	/**
	 * Exits the course
	 * 
	 * @author Matt Perkins
	 */
	public class ExitSCOCommand extends AbstractScientiaCommand
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
		
		public function ExitSCOCommand()
		{
			super();
		}
		
		override public function execute():void 
		{
			lmsUpdater.disconnect();
		}
		
	}
}
