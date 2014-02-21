package scientia.utils
{
	import com.nudoru.lms.ILMSProtocolFacade;
	import scientia.model.IScientiaModel;
	
	/**
	 * @author Matt Perkins
	 */
	public interface ILMSUpdater
	{
		
		function get model():IScientiaModel;
		function set model(value:IScientiaModel):void;
		function get lmsProtocol():ILMSProtocolFacade;
		function set lmsProtocol(value:ILMSProtocolFacade):void;
		function update():void;
		function disconnect():void;
		
	}
}
