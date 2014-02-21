package com.nudoru.lms.scorm
{
	import com.nudoru.lms.AbstractLMSProtocolFacade;
	import com.nudoru.lms.LMSType;
	import com.nudoru.debug.Debugger;
	import com.nudoru.lms.ILMSProtocolFacade;

	
	/**
	 * General connection manager for all SCORM LMS interaction. 
	 * Wraps the Pipwerks SCORM adapter to standardize syntax and make communication less error prone
	 * 
	 * @author Matt Perkins
	 */
	public class SCORMFacade extends AbstractLMSProtocolFacade implements ILMSProtocolFacade
	{
		//---------------------------------------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------------------------------------
		
		protected var _PipwerksAdapter:PipwerksSCORM;
		protected var _SCORMVersion:String;

		//---------------------------------------------------------------------
		//
		//	GETTER/SETTER
		//
		//---------------------------------------------------------------------
		
		/**
		 * Learner's score
		 */
		override public function set score(value:int):void
		{
			if (!LMSCommunicationAllowed) return;
			// enforce value limits
			if (value > 100) value = 100;
			if (value < 0) value = 0;
			
			_CacheScore = value;
			
			lastCommand = "Set score to: " + _CacheScore;
			
			if (_SCORMVersion == LMSType.SCORM2004) setAPIVariable("cmi.score.raw", String(_CacheScore));
				else setAPIVariable("cmi.core.score.raw", String(_CacheScore));
		}

		/**
		 * Bookmarked location
		 */
		override public function set lastLocation(value:String):void
		{
			if (!LMSCommunicationAllowed) return;
			
			_CacheLastLocation = value;
			
			lastCommand = "Set last location to: " + _CacheLastLocation;
			
			if (_SCORMVersion == LMSType.SCORM2004) setAPIVariable("cmi.location", _CacheLastLocation);
				else setAPIVariable("cmi.core.lesson_location", _CacheLastLocation);
		}

		/**
		 * State data
		 */
		override public function set suspendData(value:String):void
		{
			if (!LMSCommunicationAllowed) return;
			
			_CacheSuspendData = value;
			
			lastCommand = "Set susspend data to: " + _CacheSuspendData;
			
			if (_SCORMVersion == LMSType.SCORM2004) setAPIVariable("cmi.suspend_data", _CacheSuspendData);
				else setAPIVariable("cmi.suspend_data", _CacheSuspendData);
		}

		/**
		 * How long as the sesson been established
		 */
		override public function set sessionTime(value:String):void
		{
			if (!LMSCommunicationAllowed) return;
			
			_CacheSessionTime = value;
			
			lastCommand = "Set sesstion time to: " + _CacheSessionTime;
			
			if (_SCORMVersion == LMSType.SCORM2004) setAPIVariable("cmi.session_time", _CacheSessionTime);
				else setAPIVariable("cmi.core.session_time", _CacheSessionTime);
		}

		/**
		 * Status of the SCO
		 */
		override public function set lessonStatus(value:String):void
		{
			if (!LMSCommunicationAllowed) return;
			
			_CacheLessonStatus = value;
			
			lastCommand = "Set lesson status to: " + _CacheLessonStatus;
			
			if (_SCORMVersion == LMSType.SCORM2004) setAPIVariable("cmi.completion_status", _CacheLessonStatus);
				else setAPIVariable("cmi.core.lesson_status", _CacheLessonStatus);
		}

		/**
		 * Success status of the SCO (SCORM 2004) only
		 */
		public function get successStatus():String
		{
			return _CacheSuccessStatus;
		}

		public function set successStatus(value:String):void
		{
			if (!LMSCommunicationAllowed) return;
			// only allow for SCORM2004 since it will generate an error w/ 1.2
			if (_SCORMVersion != LMSType.SCORM2004) return;
			
			_CacheSuccessStatus = value;
			
			lastCommand = "Set success status to: " + _CacheSuccessStatus;
			
			setAPIVariable("cmi.success_status", _CacheSuccessStatus);
		}

		//---------------------------------------------------------------------
		//
		//	INITIALIZATION
		//
		//---------------------------------------------------------------------

		/**
		 * Constructor
		 */
		public function SCORMFacade():void {}

		/**
		 * Initialize the LMS Connector. If version isn't passed, it will default to 1.2
		 * @param	trackingmode
		 */
		override public function initialize(data:String=undefined):void
		{
			Debugger.instance.add("SCORM LMS initializing", this);
			
			super.initialize(data);
			
			if(!data ) _SCORMVersion = LMSType.SCORM12;
				else _SCORMVersion = data;

			_PipwerksAdapter = new PipwerksSCORM();
			
			initializeLMS();
		}

		/**
		 * Initialize the connection to the LMS
		 * @return
		 */
		override protected function initializeLMS():void
		{
			Debugger.instance.add("scorm facade inititalizing ...");
			
			_LMSConnectionActive = _PipwerksAdapter.connect();
			
			if (_LMSConnectionActive)
			{
				Debugger.instance.add("scorm facade connect SUCCESS");

				if (_SCORMVersion == LMSType.SCORM2004)
				{
					_CacheLessonStatus = _PipwerksAdapter.get("cmi.completion_status");
					_CacheLastLocation = _PipwerksAdapter.get("cmi.location");
					_CacheSuspendData = _PipwerksAdapter.get("cmi.suspend_data");
					_RetrievedStudentName = _PipwerksAdapter.get("cmi.learner_name");
					_RetrievedStudentID = _PipwerksAdapter.get("cmi.learner_id");
				}
				else
				{
					_CacheLessonStatus = _PipwerksAdapter.get("cmi.core.lesson_status");
					_CacheLastLocation = _PipwerksAdapter.get("cmi.core.lesson_location");
					_CacheSuspendData = _PipwerksAdapter.get("cmi.suspend_data");
					_RetrievedStudentName = _PipwerksAdapter.get("cmi.core.student_name");
					_RetrievedStudentID = _PipwerksAdapter.get("cmi.core.student_id");
				}

				Debugger.instance.add(getLaunchData(), this);

				if (lessonStatus == SCOStatus.COMPLETE ||
					lessonStatus == SCOStatus.PASS || 
					lessonStatus == SCOStatus.FAIL)
				{
					Debugger.instance.add("scorm facade course already completed, disconnecting");
					_SuspendLMSCommunication = true;
				}
				else
				{
					Debugger.instance.add("scorm facade setting incomplete");
					_SuspendLMSCommunication = false;
					setStatusIncomplete();
					_SessionTimer.start();
				}

				lmsConnectSignal.dispatch();
			}
			else
			{
				lmsCannotConnectSignal.dispatch();
			}
		}

		protected function setAPIVariable(variable:String, value:String):void
		{
			success = _PipwerksAdapter.set(variable, value);
		}

		//---------------------------------------------------------------------
		//
		//	CONNECTION
		//
		//---------------------------------------------------------------------

		/**
		 * For the SCORM API to commit data to the LMS
		 */
		override public function commit():void
		{
			if (!LMSCommunicationAllowed) return;
			
			_PipwerksAdapter.save();
		}

		/**
		 * Disconnect from the LMS and end the session. 
		 * On Saba, this closes the window, must be called at the end.
		 */
		override public function disconnect():void
		{
			if (!_LMSConnectionActive) return;
			
			Debugger.instance.add("scorm facade, disconnecting");
			
			_PipwerksAdapter.disconnect();

			_lmsDisconnectSignal.dispatch();
		}

		//---------------------------------------------------------------------
		//
		//	STATUS
		//
		//---------------------------------------------------------------------

		/**
		 * Set the lesson status to incomplete
		 */
		override public function setStatusIncomplete():void
		{
			lessonStatus = SCOStatus.INCOMPLETE;
		}

		/**
		 * Set the lesson status to completed
		 */
		override public function setStatusComplete():void
		{
			stopSessionTimer();
			lessonStatus = SCOStatus.COMPLETE;
			successStatus = SCOStatus.SUCCESSSTATUS_PASSED;
		}

		/**
		 * Set the lesson status to pass
		 */
		override public function setStatusPass():void
		{
			stopSessionTimer();
			lessonStatus = SCOStatus.PASS;
			successStatus = SCOStatus.SUCCESSSTATUS_PASSED;
		}

		/**
		 * Set the lesson status to fail
		 */
		override public function setStatusFail():void
		{
			stopSessionTimer();
			lessonStatus = SCOStatus.FAIL;
			successStatus = SCOStatus.SUCCESSSTATUS_FAILED;
		}

		//---------------------------------------------------------------------
		//
		//	TIMER METHODS
		//
		//---------------------------------------------------------------------

		/**
		 * Get the session time in proper format for the SCORM version
		 * @return
		 */
		override public function getSessionTime():String
		{
			var stime:String = "";
			if (_SCORMVersion == LMSType.SCORM2004)
			{
				// type timeinterval (second, 10,2)
				var t:Array = _SessionTimer.elapsedTimeFormattedHHMMSS().split(":");
				stime = SCORMDataTypes.toTimeIntervalSecond10(t[0], t[1], t[2]);
			}
			else
			{
				// scorm 1.2, HHHH:MM:SS.SS
				stime = "00" + _SessionTimer.elapsedTimeFormattedHHMMSS() + ".0";
			}
			return stime;
		}

	}
}