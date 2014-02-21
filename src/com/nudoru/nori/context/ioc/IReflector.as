package com.nudoru.nori.context.ioc
{
	import flash.system.ApplicationDomain;
	
	/**
	 * Interface built from SwiftSuspenders IOC
	 */
	public interface IReflector
	{
		function getClass(value : *, applicationDomain : ApplicationDomain = null):Class;
		function getFQCN(value : *, replaceColons : Boolean = false):String;
	}
}