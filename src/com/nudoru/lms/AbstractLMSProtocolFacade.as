package com.nudoru.lms
{
	import com.nudoru.lms.scorm.SCOStatus;
	import com.nudoru.debug.Debugger;
	import com.nudoru.lms.ILMSProtocolFacade;
	import com.nudoru.utilities.TimeKeeper;

	import org.osflash.signals.Signal;
	
	/**
	 * Abstract Facade for various LMS Protocols. Extend to provide specific LMS functionality
	 * Used for testing or when communication to the LMS is not possible
	 * 
	 * @author Matt Perkins
	 */
	public class AbstractLMSProtocolFacade implements ILMSProtocolFacade
	{
		
		//---------------------------------------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------------------------------------
		
		protected var _CacheLessonStatus:String;
		protected var _CacheSuccessStatus:String;
		protected var _CacheLastLocation:String;
		protected var _CacheSuspendData:String;
		protected var _CacheScore:int;
		protected var _CacheSessionTime:String;
		protected var _RetrievedStudentName:String;
		protected var _RetrievedStudentID:String;
		protected var _LMSConnectionActive:Boolean;
		
		/**
		 * SuspendLMSCommunication allows for the LMS to be connected, but for no data to be sent.
		 * This is required if the course has been completed and you do not want to overwrite
		 * and of the data that exists on the server. Eg: overwrite a "complete" with "incomplete"
		 * the LMS should enforce this, but it may not.
		 */
		protected var _SuspendLMSCommunication:Boolean;
		
		protected var _LastCommand:String;
		protected var _LastCommandSuccessStatus:Boolean;
		
		protected var _SessionTimer:TimeKeeper;
		
		protected var _lmsCannotConnectSignal:Signal = new Signal();
		protected var _lmsConnectSignal:Signal = new Signal();
		protected var _lmsDisconnectSignal:Signal = new Signal();
		protected var _lmsSuccessSignal:Signal = new Signal(String);
		protected var _lmsFailureSignal:Signal = new Signal(String);

		//---------------------------------------------------------------------
		//
		//	GETTER/SETTERS
		//
		//---------------------------------------------------------------------

		/**
		 * True if connected to the LMS
		 */
		public function get LMSConnectionActive():Boolean
		{
			return _LMSConnectionActive;
		}
		/**
		 * Student name returned from the LMS
		 */
		public function get studentName():String
		{
			return _RetrievedStudentName;
		}
		/**
		 * Student ID returned from the LMS
		 */
		public function get studentID():String
		{
			return _RetrievedStudentID;
		}
		/**
		 * Is the connector able to track.
		 */
		public function get LMSCommunicationAllowed():Boolean
		{
			if (!_LMSConnectionActive || _SuspendLMSCommunication) return false;
			return true;
		}


		public function get score():int
		{
			return _CacheScore;
		}

		public function set score(value:int):void
		{
			// enforce value limits
			if (value > 100) value = 100;
			if (value < 0) value = 0;
			_CacheScore = value;
			lastCommand = "Set score to: " + _CacheScore;
			success = true;
		}

		public function get lastLocation():String
		{
			return _CacheLastLocation;
		}

		public function set lastLocation(value:String):void
		{
			_CacheLastLocation = value;
			lastCommand = "Set last location to: " + _CacheLastLocation;
			success = true;
		}


		public function get suspendData():String
		{
			return _CacheSuspendData;
		}

		public function set suspendData(value:String):void
		{
			_CacheSuspendData = value;
			lastCommand = "Set susspend data to: " + _CacheSuspendData;
			success = true;
		}

		public function get sessionTime():String
		{
			return _CacheSessionTime;
		}

		public function set sessionTime(value:String):void
		{
			_CacheSessionTime = value;
			lastCommand = "Set sesstion time to: " + _CacheSessionTime;
			success = true;
		}

		public function get lessonStatus():String
		{
			return _CacheLessonStatus;
		}

		public function set lessonStatus(value:String):void
		{
			_CacheLessonStatus = value;
			lastCommand = "Set lesson status to: " + _CacheLessonStatus;
			success = true;
		}

		/**
		 * Result of a LMS operation
		 */
		public function get success():Boolean
		{
			return _LastCommandSuccessStatus;
		}

		public function set success(value:Boolean):void
		{
			_LastCommandSuccessStatus = value;
			if (!_LastCommandSuccessStatus)
			{
				Debugger.instance.add("   result: FAILED");
				_lmsFailureSignal.dispatch(lastCommand);
			}
			else
			{
				Debugger.instance.add("   result: SUCCESSFUL");
				_lmsSuccessSignal.dispatch(lastCommand);
			}
		}

		public function get lastCommand():String
		{
			return _LastCommand;
		}

		public function set lastCommand(value:String):void
		{
			_LastCommand = value;
			Debugger.instance.add("LMS, " + _LastCommand);
		}

		public function get lmsCannotConnectSignal():Signal
		{
			return _lmsCannotConnectSignal;
		}

		public function get lmsConnectSignal():Signal
		{
			return _lmsConnectSignal;
		}

		public function get lmsDisconnectSignal():Signal
		{
			return _lmsDisconnectSignal;
		}

		public function get lmsSuccessSignal():Signal
		{
			return _lmsSuccessSignal;
		}

		public function get lmsFailureSignal():Signal
		{
			return _lmsFailureSignal;
		}

		//---------------------------------------------------------------------
		//
		//	INITIALIZATION
		//
		//---------------------------------------------------------------------

		public function AbstractLMSProtocolFacade():void {}

		public function initialize(data:String=undefined):void
		{
			_CacheLastLocation = "";
			_CacheSuspendData = "";
			_CacheScore = -1;
			_CacheSessionTime = "00:00:01";
			_RetrievedStudentName = "Name,Student";
			_RetrievedStudentID = "xxxxxx";
			_SuspendLMSCommunication = true;
			_LMSConnectionActive = false;
			_SessionTimer = new TimeKeeper("_lms_session_timer");
		}

		protected function initializeLMS():void
		{
			_lmsConnectSignal.dispatch();
		}

		//---------------------------------------------------------------------
		//
		//	CONNECTION
		//
		//---------------------------------------------------------------------

		public function commit():void {}

		public function disconnect():void 
		{
			_LMSConnectionActive = false;
		}

		//---------------------------------------------------------------------
		//
		//	STATUS
		//
		//---------------------------------------------------------------------

		public function setStatusIncomplete():void
		{
			lessonStatus = SCOStatus.INCOMPLETE;
		}

		public function setStatusComplete():void
		{
			stopSessionTimer();
			lessonStatus = SCOStatus.COMPLETE;
		}

		public function setStatusPass():void
		{
			stopSessionTimer();
			lessonStatus = SCOStatus.PASS;
		}

		public function setStatusFail():void
		{
			stopSessionTimer();
			lessonStatus = SCOStatus.FAIL;
		}

		//---------------------------------------------------------------------
		//
		//	UTIL
		//
		//---------------------------------------------------------------------

		public function getLaunchData():String
		{
			var t:String = "~~~~~~~~~~\n";
			t += "LMS stu name is: '" + studentName + "'\n";
			t += "LMS stu id is: '" + studentID + "'\n";
			t += "LMS lstatus is: '" + lessonStatus + "'\n";
			t += "LMS last loc is: '" + lastLocation + "'\n";
			t += "LMS susp data is: '" + suspendData + "'\n";
			t += "~~~~~~~~~~";
			return t;
		}

		public function getSessionTime():String
		{
			return _SessionTimer.elapsedTimeFormattedHHMMSS();
		}

		public function stopSessionTimer():void
		{
			if(!_SessionTimer.isRunning) return;
			sessionTime = getSessionTime();
			_SessionTimer.stop();
		}

	}
}