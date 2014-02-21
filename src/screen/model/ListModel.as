package screen.model
{
	
	import com.nudoru.lms.scorm.InteractionObject;
	
	/**
	 * List model
	 * @author Matt Perkins
	 */
	public class ListModel extends AbstractScreenModel implements IListModel
	{
		public var _items		:Vector.<ListItemModel>;

		public function get numItems():int { return _items.length; }
		
		public function get interactionObject():InteractionObject
		{
			//TODO this is temporary
			return new InteractionObject();
		}
		
		public function set interactionObject(value:InteractionObject):void
		{
			//
		}
		
		public function ListModel(data:XML):void
		{
			super(data);
			
			_items = new Vector.<ListItemModel>();
			
			for (var i:int = 0, len:int = _xml.item.length(); i < len; i++)
			{
				_items.push(new ListItemModel(_xml.item[i]));
			}
		}
		
		public function getItemByIdx(i:int):ListItemModel
		{
			return _items[i];
		}
		
		public function getItemIdxByID(id:String):int
		{
			for (var i:int = 0, len:int = _items.length; i < len; i++)
			{
				if (_items[i].id == id) return i;
			}
			return -1;
		}
		
		public function getItemByID(id:String):ListItemModel
		{
			var idx:int = getItemIdxByID(id);
			if (idx > -1) return _items[idx];
			return undefined;
		}

		public function allItemsCompleted():Boolean
		{
			for (var i:int = 0, len:int = _items.length; i < len; i++)
			{
				if (!_items[i].completed) return false;
			}
			return true;
		}
		
	}
	
}