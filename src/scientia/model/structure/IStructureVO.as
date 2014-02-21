package scientia.model.structure
{
	import scientia.model.structure.INodeVO;

	/**
	 * @author Matt Perkins
	 */
	public interface IStructureVO extends INodeVO
	{
		function get currentNavigationDirection():int;
		function firstScreen():IScreenVO;
		function getCurrentScreen():IScreenVO;
		function gotoScreenByID(id:String):IScreenVO;
		function isLinearPreviousScreen():Boolean;
		function isLinearNextScreen():Boolean;
		function gotoPreviousScreen():IScreenVO;
		function gotoNextScreen():IScreenVO;
		function getScreenByID(id:String):IScreenVO;
		function getCurrentModuleScreenIndex():int;
		function getCurrentModuleNumScreens():int;
		function getModuleScreenID(mindex:int, sindex:int):String;
		function getModuleScreenType(mindex:int, sindex:int):String;
		function getModuleScreenName(mindex:int, sindex:int):String;
		function getModuleScreenStatus(mindex:int, sindex:int):int;
		function setModuleScreenStatus(mindex:int, sindex:int, status:int):void;
		function areAllModulesCompleted():Boolean;
		function getAllScreenStatusString():String;
		function getNumberOfScoredScreens():int;
		function getNumberOfScreensWithStatus(status:int):int;
	}
}
