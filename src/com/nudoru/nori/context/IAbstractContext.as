package com.nudoru.nori.context
{
	import com.nudoru.nori.events.ICommandMap;
	import com.nudoru.nori.context.ioc.IInjector;
	import com.nudoru.nori.context.ioc.IReflector;
	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;

	public interface IAbstractContext
	{
		function get injector():IInjector;
		function get reflector():IReflector;
		function get contextView():DisplayObjectContainer;
		function get commandMap():ICommandMap;
		function get eventDispatcher():IEventDispatcher;
		
		function initialize(cv:DisplayObjectContainer):void;
		function run():void;
		function destroy():void;
	}
}