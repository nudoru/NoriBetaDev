package com.nudoru.noriplugins.appview.view
{
	import com.nudoru.components.IWindowManager;
	import com.nudoru.nori.mvc.view.IAbstractNoriView;
	import com.nudoru.utilities.AssetsProxy.IAssetsProxy;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import org.osflash.signals.Signal;


	public interface IAppView extends IAbstractNoriView
	{
		function get assetProxy():IAssetsProxy;
		function set assetProxy(value:IAssetsProxy):void;
		function get windowManager():IWindowManager;
		function set windowManager(windowManager:IWindowManager):void;
		function get appScalableBGMC():MovieClip;
 		function get appUIView():Sprite;
 		function get appBackgroundLayer():Sprite;
		function get appUILayer():Sprite;
		function get appUIWidth():int;
		function get appUIHeight():int;
		function get viewWidth():int;
		function get viewHeight():int;
		function get onStageResizeSignal():Signal;
		function get onStageFocusInSignal():Signal;
		function get onStageFocusOutSignal():Signal;
		function get onStageKeyPressSignal():Signal;

		function suspendRender():void;
		function resumeRender():void;
		function showModalMessage(title:String, content:String):void;
		function showMessage(title:String, content:String):void;
		function closeTopWindow():void;
		function initialzeVisualDebugger():void;
		function toggleDebug():void;
		function showDebug():void;
		function hideDebug():void;
		function getAssetAsMC(linkage:String):MovieClip;
		function getStageSymbol(name:String):MovieClip;
		function getLibrarySymbol(n:String):Object;
	}
}