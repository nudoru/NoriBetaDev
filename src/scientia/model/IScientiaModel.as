package scientia.model
{
	import com.nudoru.lms.scorm.InteractionObject;
	import com.nudoru.noriplugins.bindablemodel.model.IBindableModel;
	import scientia.model.VOs.ConfigVO;
	import scientia.model.structure.IScreenVO;
	import scientia.model.structure.IStructureVO;

	
	public interface IScientiaModel extends IBindableModel
	{
		function get modelConfigDeserializer():IModelConfigurationDeserializer;
		function set modelConfigDeserializer(modelConfigVOFactory:IModelConfigurationDeserializer):void;
		function get configVO():ConfigVO;
		function get structureVO():IStructureVO;
		function get LSOID():String;

		function getSuspendData():String;
		function processSuspendData(data:String):Boolean;
		function getCurrentScreen():IScreenVO;
		function gotoFirstScreen():IScreenVO;
		function isLinearPreviousScreen():Boolean;
		function isLinearNextScreen():Boolean;
		function isNextScreen():Boolean;
		function isPreviousScreen():Boolean;
		function gotoPreviousScreen():IScreenVO;
		function gotoNextScreen():IScreenVO;
		function gotoScreenID(id:String):IScreenVO;
		function getScreenID(id:String):IScreenVO;
		function getPageOfTotalPagesString():String;
		function setScreenIDStatusInteractionObject(screenid:String, status:int, interactionobject:InteractionObject=undefined):void;
		function setScreenIDStatusInteractionObjectAndBroadcast(screenid:String, status:int, interactionobject:InteractionObject=undefined):void

		function isComplete():Boolean;
		
		function getCurrentScorePercentage():int;
		function isPassing():Boolean;
	}
}