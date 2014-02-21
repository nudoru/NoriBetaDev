package com.nudoru.nori.mvc
{
	import com.nudoru.nori.events.ICommandMap;
	import flash.events.IEventDispatcher;
	/**
	 * @author Matt Perkins
	 */
	public interface IActor
	{
		function get eventDispatcher():IEventDispatcher;
		function set eventDispatcher(eventDispatcher:IEventDispatcher):void;
		function get commandMap():ICommandMap;
		function set commandMap(eventMap:ICommandMap):void;
	}
}
