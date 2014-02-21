package scientia.controller.commands
{
	import com.nudoru.lms.ILMSProtocolFacade;
	import com.nudoru.constants.ObjectStatus;
	import com.asual.ISWFAddress;
	import com.nudoru.services.ICookieService;

	/**
	 * Handles what should take place when the Model dispatches a screen change event.
	 */
	public class UpdateOnScreenChangeCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		private var _sharedObjectSvc:ICookieService;
		private var _swfAddress:ISWFAddress;
		private var _lmsProtocol:ILMSProtocolFacade;
		private var _screenID:String;

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

		public function get lmsProtocol():ILMSProtocolFacade
		{
			return _lmsProtocol;
		}

		[Inject]
		public function set lmsProtocol(lmsProtocol:ILMSProtocolFacade):void
		{
			_lmsProtocol = lmsProtocol;
		}

		public function UpdateOnScreenChangeCommand():void
		{
			super();
		}

		/**
		 * Updates the View when the Model changes the current screen
		 */
		override public function execute():void
		{
			_screenID = data[0];

			// check the status
			if(model.getCurrentScreen().status == ObjectStatus.NOT_ATTEMPTED) model.getCurrentScreen().status = ObjectStatus.INCOMPLETE;
			// show the screen
			view.showScreen(model.getCurrentScreen(), model.structureVO.currentNavigationDirection);
			// set page number
			view.setPageNumber(model.getPageOfTotalPagesString());

			updateNavigationOnScreenAvailability();
			updateNavigationOnScreenStatus();

			updateLocalTracking();

			if(lmsProtocol.LMSCommunicationAllowed) lmsProtocol.lastLocation = _screenID;
		}

		private function updateNavigationOnScreenStatus():void
		{
			if(model.getCurrentScreen().scored && ! model.getCurrentScreen().isComplete()) view.disableNextButton();
		}

		private function updateNavigationOnScreenAvailability():void
		{
			if(model.structureVO.isLinearPreviousScreen()) view.enableBackButton();
			else view.disableBackButton();
			if(model.structureVO.isLinearNextScreen()) view.enableNextButton();
			else view.disableNextButton();
		}

		private function updateLocalTracking():void
		{
			if(!lmsProtocol.LMSConnectionActive)
			{
				if(model.configVO.useSWFAddress) _swfAddress.setValue("/" + _screenID + "/");	
			}
			if(model.configVO.useLSO) sharedObjectSvc.save(model.LSOID, model.getSuspendData());
		}
	}
}