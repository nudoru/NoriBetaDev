package scientia.controller.commands.startup 
{
	import com.nudoru.debug.Debugger;
	import com.nudoru.lms.ILMSProtocolFacade;
	import scientia.controller.commands.AbstractScientiaCommand;
	import scientia.controller.commands.IAbstractScientiaCommand;

	/**
	 * Handles the event when the the Model needs to jump to a new screen
	 */
	public class StartupWithLMSCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		
		private var _LMSProtocol:ILMSProtocolFacade;

		public function get lmsProtocol():ILMSProtocolFacade
		{
			return _LMSProtocol;
		}
		
		[Inject]
		public function set lmsProtocol(value:ILMSProtocolFacade):void
		{
			_LMSProtocol = value;
		}
		
		public function StartupWithLMSCommand():void
		{
			super();
		}

		override public function execute():void {
			Debugger.instance.add("StartupWithLMSCommand", this);
			
			if(lmsProtocol.suspendData) model.processSuspendData(lmsProtocol.suspendData);
			if(lmsProtocol.lastLocation) model.gotoScreenID(lmsProtocol.lastLocation);
				else model.gotoFirstScreen();
		}
		
	}

}