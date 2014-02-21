package com.nudoru.lms
{
	import com.nudoru.debug.Debugger;
	
	/**
	 * Null LMS Communication Protocol
	 * Used for testing or when communication to the LMS is not possible
	 * 
	 * @author Matt Perkins
	 */
	public class NullFacade extends AbstractLMSProtocolFacade implements ILMSProtocolFacade
	{
		
		public function NullFacade():void {}

		override public function initialize(data:String=undefined):void
		{
			Debugger.instance.add("null facade initializing", this);
			super.initialize(data);
			initializeLMS();
		}

	}
}