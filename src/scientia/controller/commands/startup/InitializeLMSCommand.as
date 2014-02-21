package scientia.controller.commands.startup 
{
	import scientia.events.signals.StartupSignals;
	import com.nudoru.utilities.HTMLContainerUtils;
	import com.nudoru.lms.LMSType;
	import com.nudoru.debug.Debugger;
	import com.nudoru.lms.ILMSProtocolFacade;
	import scientia.controller.commands.AbstractScientiaCommand;
	import scientia.controller.commands.IAbstractScientiaCommand;

	/**
	 * Handles the event when the the Model needs to jump to a new screen
	 */
	public class InitializeLMSCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
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
		
		public function InitializeLMSCommand():void
		{
			super();
		}
		
		/**
		 * Handle command neccessary to jump to a new screen.
		 */
		override public function execute():void {
			Debugger.instance.add("InitializeLMSCommand", this);
			
			initializeLMSProtocol();
		}
		
		private function initializeLMSProtocol():void
		{
			var lmsInitString:String;
			
			if(_model.configVO.lmsMode == LMSType.SCORM12 || _model.configVO.lmsMode == LMSType.SCORM2004) lmsInitString = _model.configVO.lmsMode;
				else lmsInitString = HTMLContainerUtils.callJSFunctionAndReturnResult("getWindowLocation");
			
			// AICC Testing
			//lmsInitString = "https://sub.domain.com/wb_content/coursecode/lmsdefault.htm?aicc_sid=3032659%2CA001&aicc_url=sub.domain.com%2Fns-bin%2Fdocentnsapi%2Flms%2Capp1%2C2151%2FSQN%3D-76165634%2CCMD%3DGET%2Cfile%3Daicc_catcher.jsm%2CSVR%3Dpldd005.csm.fub.com%3A48673%2CSID%3DPLDD005.CSM.FUB.COM%3A48673-A9CA-2-B1FD32EA-00BDB3E0%2F";
			
			Debugger.instance.add("LMS initializer: "+lmsInitString, this);
			
			lmsProtocol.lmsConnectSignal.addOnce(onLMSInitialized);
			lmsProtocol.lmsCannotConnectSignal.addOnce(onLMSNotInitialized);
			lmsProtocol.initialize(lmsInitString);
		}

		private function onLMSInitialized():void
		{
			Debugger.instance.add("LMS CONNECTED", this);
			StartupSignals.START_UP_LMS.dispatch();
		}
		
		private function onLMSNotInitialized():void
		{
			Debugger.instance.add("CANNOT CONNECT TO THE LMS", this);	
			StartupSignals.START_UP_NO_LMS.dispatch();
		}
		
	}

}