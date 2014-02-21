package com.nudoru.components
{
	
	/**
	 * Data type for a Window
	 */
	public interface IWindow extends IAbstractVisualComponent
	{
		
		function get windowType():String;
		
		function get modal():Boolean;
		
		function setDraggable():void;
		
		function removeDraggable():void;
		
		function addComponent(component:*, initObj:Object, x:int, y:int):void;
		
		function alignStageCenter():void;
	}
}