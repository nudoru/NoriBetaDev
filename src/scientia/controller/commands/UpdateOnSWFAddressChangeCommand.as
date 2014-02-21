package scientia.controller.commands 
{
	import com.asual.ISWFAddress;
	import scientia.events.signals.NavigationSignals;


	/**
	 * Handles the SWFAddress change event
	 */
	public class UpdateOnSWFAddressChangeCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		
		protected var _swfAddress			:ISWFAddress;
		
		[Inject]
		public function set swfAddress(value:ISWFAddress):void
		{
			_swfAddress = value;
		}
		
		public function get swfAddress():ISWFAddress
		{
			return _swfAddress;
		}
		
		public function UpdateOnSWFAddressChangeCommand():void
		{
			super();
		}
		
		/**
		 * Updates the model when the SWF address changes
		 */
		override public function execute():void {
			//Debugger.instance.add("OnSWFAddressChangeCommand, execute: "+_swfAddress.getValue(), this);
			
			if (_swfAddress.getValue() == "/")
			{
				model.gotoFirstScreen();
			}
			else
			{
				var loc:String = _swfAddress.getValue().split("/")[1];
				if (loc != model.getCurrentScreen().id) NavigationSignals.GOTO_SCREEN_ID.dispatch(loc);
			}

		}
		
	}

}