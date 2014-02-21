package com.nudoru.nori.events
{
	import com.nudoru.nori.context.ioc.IInjector;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import org.osflash.signals.Signal;


	
	public interface ICommandMap extends IEventDispatcher
	{
		function get verbose():Boolean;
		function set verbose(value:Boolean):void;
		function get injector():IInjector
		function set injector(injector:IInjector):void

		function mapEventCommand(eventType:String, cmd:Class):void;
		function executeEventCommand(event:Event):void;
		function removeEventCommand(eventType:String):void;
		function hasEventCommand(eventType:String):Boolean;

		function mapSignalCommand(signal:Signal, cmd:Class, cache:Boolean = false):void;
		function executeSignalCommand(signal:Signal, args:Array):void;
		function removeSignalCommand(signal:Signal):void;
		function hasSignalCommand(signal:Signal):Boolean;
		function destroy():void;
	}
}