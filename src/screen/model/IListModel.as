package screen.model
{
	import com.nudoru.lms.scorm.InteractionObject;

	
	public interface IListModel extends IAbstractScreenModel
	{
		function get numItems():int;
		function get interactionObject():InteractionObject;
		function set interactionObject(value:InteractionObject):void;
		function getItemByIdx(i:int):ListItemModel;
		function getItemIdxByID(id:String):int;
		function getItemByID(id:String):ListItemModel;
		function allItemsCompleted():Boolean;
	}
}