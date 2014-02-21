package scientia.controller.commands 
{
	import com.nudoru.constants.KeyDict;
	import flash.events.KeyboardEvent;
	import scientia.events.signals.NavigationSignals;

	/**
	 * Handles keypress events
	 */
	public class RespondToKeyPressCommand extends AbstractScientiaCommand implements IAbstractScientiaCommand
	{
		public function RespondToKeyPressCommand():void
		{
			super();
		}
		
		/**
		 * Do something
		 */
		override public function execute():void {
			//Debugger.instance.add("HandleKeyPressCommand, execute");
	
			var kbEvent:KeyboardEvent = data[0];
			
			var keyCode:int = kbEvent.keyCode;
			var isCtrl:Boolean = kbEvent.ctrlKey;
			var isShift:Boolean = kbEvent.shiftKey;
			var isAlt:Boolean = kbEvent.altKey;
			var keyLocation:int = kbEvent.keyLocation;
			
			//trace("keyCode " + keyCode);
			
			if (isCtrl && isShift && keyCode == KeyDict.ITEM_1) view.toggleDebug();
			
			if (keyCode == KeyDict.ARROW_RIGHT) NavigationSignals.GOTO_NEXT_SCREEN.dispatch();
			if (keyCode == KeyDict.ARROW_LEFT) NavigationSignals.GOTO_PREVIOUS_SCREEN.dispatch();
			if (keyCode == KeyDict.ESC) view.closeTopWindow();
		}

		
	}

}