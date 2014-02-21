package com.nudoru.components
{

	import com.nudoru.visual.IDisplayObject;
	
	/**
	 * Data type for a view class
	 */
	public interface IAbstractVisualComponent extends IDisplayObject
	{
		/**
		 * Any initialization steps
		 */
		function initialize(data:*= null):void;
		/**
		 * Draw the view
		 */
		function render():void;
		/**
		 * Get the size of the component
		 * @return Object with width and heigh props
		 */
		function measure():Object;
		/**
		 * Update the display
		 */
		function update(data:*= null):void;
		/**
		 * Unload the view
		 */
		function destroy():void;
	}
}