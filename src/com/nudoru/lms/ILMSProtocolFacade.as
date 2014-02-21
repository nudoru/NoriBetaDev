package com.nudoru.lms
{
	import org.osflash.signals.Signal;

	
	public interface ILMSProtocolFacade
	{
		function get LMSConnectionActive():Boolean;
		function get LMSCommunicationAllowed():Boolean;
		
		function get studentName():String;
		function get studentID():String;
		function get lastLocation():String;
		function set lastLocation(value:String):void;
		function get suspendData():String;
		function set suspendData(value:String):void;
		
		function get score():int;
		function set score(value:int):void;
		
		function get sessionTime():String;
		function set sessionTime(value:String):void;
		function get lessonStatus():String;
		function set lessonStatus(value:String):void;
		
		//function get successStatus():String;
		//function set successStatus(value:String):void;
		
		function get success():Boolean;
		function set success(value:Boolean):void;

		function get lastCommand():String;
		function set lastCommand(value:String):void;
		
		function get lmsCannotConnectSignal():Signal;
		function get lmsConnectSignal():Signal;
		function get lmsDisconnectSignal():Signal;
		function get lmsSuccessSignal():Signal;
		function get lmsFailureSignal():Signal;
		
		function initialize(data:String=undefined):void;
		
		function getLaunchData():String;
		
		function getSessionTime():String;
		function stopSessionTimer():void;
		
		function setStatusIncomplete():void;
		function setStatusComplete():void;
		function setStatusPass():void;
		function setStatusFail():void;
		
		function commit():void;
		
		function disconnect():void;
	}
}