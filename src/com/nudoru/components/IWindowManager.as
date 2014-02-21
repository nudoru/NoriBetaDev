package com.nudoru.components
{
	import flash.display.MovieClip;

	public interface IWindowManager extends IAbstractVisualComponent
	{
		function showMessage(title:String,message:String,emphasis:Boolean=false,height:int=250,modal:Boolean=false):IWindow;
		function showMessageCustomWindow(title:String,message:String,winmc:MovieClip,width:int,close:String="",modal:Boolean=false):void;
		function closeTopWindow():void;
		function removeAllWindows():void;
	}
}