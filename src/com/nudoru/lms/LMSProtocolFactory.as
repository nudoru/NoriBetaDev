package com.nudoru.lms
{
	import com.nudoru.debug.Debugger;
	import com.nudoru.lms.scorm.SCORMFacade;
	import com.nudoru.lms.aicc.AICCFacade;
	
	/**
	 * Gets an instance of an LMS Protocol Facade based on the passed type
	 * If the type is not found, a Null facade instance is returned
	 * @author Matt Perkins
	 */
	public class LMSProtocolFactory implements ILMSProtocolFactory
	{
		
		public static function createLMSProtocol(type:String):ILMSProtocolFacade
		{
					
			switch(type)
			{
				case LMSType.AICC:
					return new AICCFacade();
				case LMSType.SCORM12:
				case LMSType.SCORM2004:
					return new SCORMFacade();
			}

			Debugger.instance.add("LMS type not found: "+type);
			return new NullFacade();
		}
		
	}
}
