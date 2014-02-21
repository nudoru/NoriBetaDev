package com.nudoru.components 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * Window
	 * 
	 * Sample:
	 * 
		
	 */
	public class Border extends AbstractVisualComponent implements IAbstractVisualComponent
	{
		
		
		/**
		 * Constructor
		 */
		public function Border():void
		{
			super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
		
		
	}

}