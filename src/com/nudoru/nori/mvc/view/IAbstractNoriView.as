package com.nudoru.nori.mvc.view
{

	import flash.events.IEventDispatcher;
	import org.osflash.signals.natives.NativeSignal;
	
	/**
	 * Data type for a view class
	 */
	public interface IAbstractNoriView extends IEventDispatcher
	{
		function get addedToStageSignal() : NativeSignal;
		function get removedFromStageSignal() : NativeSignal;
		
		function get eventDispatcher():IEventDispatcher;
		function set eventDispatcher(eventDispatcher:IEventDispatcher):void;
		
		/**
		 * Any initialization steps
		 */
		function initialize(data:*=null):void;
		/**
		 * Draw the view
		 */
		function render():void;
		/**
		 * Unload the view
		 */
		function destroy():void;
	}
}