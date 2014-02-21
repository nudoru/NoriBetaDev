package com.nudoru.nori.context.ioc
{
	import flash.system.ApplicationDomain;
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;

	
	/**
	 * Interface built from SwiftSuspenders IOC
	 */
	public interface IInjector
	{
		function mapValue(whenAskedFor : Class, useValue : Object, named : String = ""):*;
		function mapSingleton(whenAskedFor : Class, named : String = ""):*;
		function mapRule(whenAskedFor : Class, useRule : *, named : String = ""):*;
		function getMapping(whenAskedFor : Class, named : String = ""):InjectionConfig;
		function injectInto(target : Object):void;
		function instantiate(clazz:Class):*;
		function unmap(clazz : Class, named : String = ""):void;
		function hasMapping(clazz : Class, named : String = ''):Boolean;
		function getInstance(clazz : Class, named : String = ''):*;
		function createChildInjector(applicationDomain:ApplicationDomain=null):Injector;
		function setApplicationDomain(applicationDomain:ApplicationDomain):void;
		function getApplicationDomain():ApplicationDomain;
		function setParentInjector(parentInjector : Injector):void;
		function getParentInjector():Injector;
	}
}