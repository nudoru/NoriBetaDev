package com.nudoru.nori.mvc.controller.commands
{
	import com.nudoru.nori.context.ioc.IInjector;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import org.osflash.signals.Signal;

	/**
	 * Data type for a command
	 */
	public interface IAbstractCommand
	{
		function get event():Event;
		function set event(value:Event):void;
		function get signal():Signal;
		function set signal(value:Signal):void;
		function get data():Array;
		function set data(value:Array):void;
		function get eventDispatcher():IEventDispatcher;
		function set eventDispatcher(eventDispatcher:IEventDispatcher):void;
		function get injector():IInjector;
		function set injector(value:IInjector):void;
		
		function execute():void;
	}
}