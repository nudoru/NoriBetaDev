package screen
{
	import com.nudoru.constants.ObjectStatus;

	import screen.controller.AbstractScreen;
	import screen.model.AbstractScreenModel;
	import screen.model.IAbstractScreenModel;

	import com.nudoru.debug.Debugger;

	/**
	 * Simple blank screen with text
	 * 
	 * @author Matt Perkins
	 */
	public class Blank extends AbstractScreen
	{
		// ---------------------------------------------------------------------
		//
		// VARIABLES
		//
		// ---------------------------------------------------------------------
		protected var _Model:IAbstractScreenModel;

		// ---------------------------------------------------------------------
		//
		// CONSTRUCTION
		//
		// ---------------------------------------------------------------------
		public function Blank():void
		{
			super();
		}

		// ---------------------------------------------------------------------
		//
		// INITIALIZATION
		//
		// ---------------------------------------------------------------------
		/**
		 * Create model from loaded XML
		 * @param	data
		 */
		override protected function parseLoadedXML(data:XML):void
		{
			_Model = new AbstractScreenModel(data);
		}

		// ---------------------------------------------------------------------
		//
		// VIEW
		//
		// ---------------------------------------------------------------------
		/**
		 * Create the view from the model
		 */
		override protected function renderScreen():void
		{
			renderCommonScreenElements(_Model);

			setScreenStatusTo(ObjectStatus.COMPLETED);
		}

		// ---------------------------------------------------------------------
		//
		// DESTROY
		//
		// ---------------------------------------------------------------------
		/**
		 * Remove listeners and display objects
		 */
		override public function destroy():void
		{
			super.destroy();
		}
	}
}