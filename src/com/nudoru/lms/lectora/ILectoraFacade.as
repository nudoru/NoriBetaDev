package com.nudoru.lms.lectora
{
	public interface ILectoraFacade
	{
		function get debugLog():Array;
		function get debugLogStr():String;
		function navigateToPage($p:String):void;
		function navigateToNextPage():void;
		function navigateToPreviousPage():void;
		function showButton($b:String):void;
		function hideButton($b:String):void;
		function setVariable($var:String, $val:String):void;
		function getVariable($var:String):String;
		function executeAction($a:String):void;
		function getFLVarStudentName():String;
		function getFLVarStudentID():String;
		function getFLVarBookmark():String;
		function setFLVarBookmark($val:String):void;
		function getFLVarSuspendData():String;
		function setFLVarSuspendData($val:String):void;
		/*function setLMSLessonLocation($val:String):void;
		function getLMSLessonLocation():String;
		function setLMSLessonStatus($val):void;
		function setLMSLessonIncomplete():void;
		function setLMSLessonComplete():void;
		function getLMSLessonStatus():String;
		function setLMSScore($val:int):void;
		function getLMSScore():int;
		function getLMSStudentName():String;
		function getLMSStudentID():String;*/
		function setTextFieldContents($tf:String, $txt:String, $algn:String = "alignleft"):void;
		function openPopUpWindow($url:String, $w:int, $h:int, $lft:int=0, $tp:int=0, $sb:int=1, $rz:int=1, $mb:int=1, $tb:int=1, $loc:int=1, $sts:int=1):void;
		function rnd(min:Number, max:Number):Number;
	}
}