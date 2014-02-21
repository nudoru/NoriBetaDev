package scientia.view.screens 
{
	import com.nudoru.nori.mvc.view.AbstractNoriView;
	import com.nudoru.nori.mvc.view.IAbstractNoriView;
	import scientia.model.structure.ScreenVO;

	/**
	 * Simple screen
	 */
	public class SimpleScreenView extends AbstractNoriView implements IAbstractNoriView
	{
		public var _data			:ScreenVO;

		/**
		 * Constructor
		 */
		public function SimpleScreenView():void
		{
				super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			_data = data as ScreenVO;
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			//text_txt.text = _data.content;
		}
		
		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			//
		}
		
	}

}