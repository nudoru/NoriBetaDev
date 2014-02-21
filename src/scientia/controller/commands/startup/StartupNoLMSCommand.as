package scientia.controller.commands.startup 
{
	import com.asual.ISWFAddress;
	import com.nudoru.debug.Debugger;
	import com.nudoru.nori.events.ICommandMap;
	import com.nudoru.services.ICookieService;
	import scientia.controller.commands.AbstractScientiaCommand;
	import scientia.controller.commands.IAbstractScientiaCommand;
	import scientia.controller.commands.UpdateOnSWFAddressChangeCommand;

	/**
	 * Handles the event when the the Model needs to jump to a new screen
	 */
	public class StartupNoLMSCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		private var _sharedObjectSvc:ICookieService;
		private var _swfAddress:ISWFAddress;
		private var _eventMap:ICommandMap;

		[Inject]
		public function set sharedObjectSvc(value:ICookieService):void
		{
			_sharedObjectSvc = value;
		}

		public function get sharedObjectSvc():ICookieService
		{
			return _sharedObjectSvc;
		}

		[Inject]
		public function set swfAddress(value:ISWFAddress):void
		{
			_swfAddress = value;
		}

		public function get swfAddress():ISWFAddress
		{
			return _swfAddress;
		}
		
		public function get eventMap():ICommandMap
		{
			return _eventMap;
		}
		
		[Inject]
		public function set eventMap(eventMap:ICommandMap):void
		{
			_eventMap = eventMap;
		}
		
		public function StartupNoLMSCommand():void
		{
			super();
		}
		
		/**
		 * Handle command neccessary to jump to a new screen.
		 */
		override public function execute():void {
			Debugger.instance.add("StartupNoLMSCommand", this);
	
			if(model.configVO.useSWFAddress) eventMap.mapSignalCommand(swfAddress.change, UpdateOnSWFAddressChangeCommand);
			if(model.configVO.useLSO) configureCookieTracking();
			
			// Start on the first screen if no tracking options are enabled
			// if tracking options are active, those will start the correct screens
			if (!model.configVO.useSWFAddress && !model.configVO.useLSO) 
			{
				Debugger.instance.add("Not using SWF address or cookie, starting", this);
				model.gotoFirstScreen();	
			}
		}

		private function configureCookieTracking():void
		{
			// Clear and cookies
			if (model.configVO.clearLSO) 
			{
				Debugger.instance.add("LSO: clearing "+_model.LSOID, this);
				sharedObjectSvc.clear(_model.LSOID);
			}
			
			// Get the cookie
			var LSOsavedData:String = sharedObjectSvc.load(_model.LSOID);
			Debugger.instance.add("LSO: returned "+model.LSOID+" = "+LSOsavedData);
			
			// Any data in the cookie?
			if (LSOsavedData)
			{
				model.processSuspendData(LSOsavedData);
			} else {
				model.gotoFirstScreen();
			}
		}

		
		
	}

}