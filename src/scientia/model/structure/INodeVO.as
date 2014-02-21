package scientia.model.structure
{
	import com.nudoru.lms.scorm.InteractionObject;
	
	public interface INodeVO
	{
		function get id():String;
		function get type():String;
		function get name():String;
		function get screenPath():String;
		function get dataURL():String;
		function get scored():Boolean;
		function get toc():Boolean;
		function get bg():String;
		function get contentXML():XML;
		function get status():int;
		function set status(value:int):void;
		function get interactionObject():InteractionObject;
		function set interactionObject(value:InteractionObject):void;
		function get numChildren():int;
		function get currentChildIndex():int;
		function set currentChildIndex(value:int):void;
		function get lastChildIndex():int;
		function isComplete():Boolean;
		function getChildID(index:int):String;
		function getChildType(index:int):String;
		function getChildName(index:int):String;
		function getChildPath(index:int):String;
		function getChildDataURL(index:int):String;
		function getChildContentXML(index:int):XML;
		function getChildStatus(index:int):int;
		function setChildStatus(index:int, status:int):void;
		function getCurrentChild():Object;
		function isNextChild():Boolean;
		function isPreviousChild():Boolean;
		function firstChild():Object;
		function lastChild():Object;
		function gotoPreviousChild():Object;
		function gotoNextChild():Object;
		function gotoChildByID(id:String):Object;
		function getChildByIndex(index:int):Object;
		function getChildIndexByID(id:String):int;
		function getChildByID(id:String):Object;
		function areAllChildrenCompleted():Boolean;
		function getAllChildrenStatusString():String;
		function getNumberOfScoredChildren():int;
		function getNumberOfChildrenWithStatus(status:int):int;
	}
}