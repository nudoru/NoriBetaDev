package com.nudoru.components 
{
	import flash.events.EventDispatcher;

	/**
	 * Very basic Data
	 * This class should be subclassed to create more enhanced functionality.
	 */
	public class AbstractDataComponent extends EventDispatcher implements IAbstractDataComponent
	{
		
		/**
		 * Get the content from the loader
		 */
		public function get content():*
		{
			return null;
		}
		
		/**
		 * Constructor
		 */
		public function AbstractDataComponent():void
		{
			super();
		}
		
		/**
		 * Initialize
		 */
		public function initialize(data:*=null):void 
		{			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Start
		 */
		public function load():void
		{
			
		}
		
		protected function calculatePercentage(current:Number, total:Number):Number
		{
			return (current / total) * 100;
		}
		
		/**
		 * Dispatch progress
		 */
		protected function dispatchProgressEvent(percentage:Number):void
		{
			var pevent:ComponentEvent = new ComponentEvent(ComponentEvent.EVENT_PROGRESS);
			pevent.data = percentage;
			dispatchEvent(pevent);
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		public function destroy():void
		{
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
	}

}