package com.nudoru.utilities.AssetsProxy
{
	import flash.system.ApplicationDomain;
	import flash.display.DisplayObject;

	import org.osflash.signals.Signal;
	
	public interface IAssetsProxy
	{
		function get assetsContent():DisplayObject;
		function get assetsAppDomain():ApplicationDomain;
		function get assets():ApplicationDomain;
		
		function get onProgressSignal():Signal;
		function get onAssetsLoadedSignal():Signal;
		function get onErrorSignal():Signal;
		
		function load(_url:String):void;
	}
}