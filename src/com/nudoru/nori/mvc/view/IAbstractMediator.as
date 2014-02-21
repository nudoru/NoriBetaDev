package com.nudoru.nori.mvc.view
{
	import com.nudoru.nori.mvc.IActor;
	
	/**
	 * @author Matt Perkins
	 */
	public interface IAbstractMediator extends IActor
	{
		function get viewComponent():Object;
		function set viewComponent(viewComponent:Object):void;
		function initialize():void;
		function onRegister():void;
		
		function destroy():void;
		
	}
}
