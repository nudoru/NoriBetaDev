package com.nudoru.nori.context
{
	import com.nudoru.nori.context.ioc.IInjector;
	import com.nudoru.nori.context.ioc.IReflector;
	import com.nudoru.nori.mvc.view.IAbstractNoriView;

	/**
	 * @author Matt Perkins
	 */
	public interface IMediatorMap
	{
		function get injector():IInjector;
		function set injector(injector:IInjector):void;
		function get reflector():IReflector;
		function set reflector(reflector:IReflector):void;
		
		function map(viewClass:*, mediatorClass:Class):void;
		function unmap(viewClass:*):void;
		function hasMediatorMapped(viewClass:*):Boolean;
		function getMediatorClass(viewClass:*):Class;
		function createMediator(viewInstance:IAbstractNoriView):void;
	}
}
