package screen.model
{
	
	/**
	 * item value object
	 * @author Matt Perkins
	 */
	public class ListItemModel extends AbstractScreenModel implements IListItemModel
	{

		protected var _completed	:Boolean;
		
		public function get completed():Boolean
		{
			return _completed;
		}
		
		public function set completed(value:Boolean):void 
		{
			_completed = value;
		}
		
		/**
		 * Constructor
		 * @param	data	XML data
		 */
		public function ListItemModel(data:XML):void
		{
			super(data);
		}

	}
	
}