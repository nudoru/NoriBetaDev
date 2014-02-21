package com.nudoru.lms.aicc
{
	import com.nudoru.lms.AbstractLMSProtocolFacade;
	import com.nudoru.debug.Debugger;
	import com.nudoru.lms.ILMSProtocolFacade;
	import com.nudoru.lms.scorm.SCOStatus;
	import com.nudoru.utilities.HTMLContainerUtils;
	import com.nudoru.utilities.TimeKeeper;

	import org.osflash.signals.Signal;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * @author Matt Perkins
	 */
	public class AICCFacade extends AbstractLMSProtocolFacade implements ILMSProtocolFacade
	{
		//---------------------------------------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------------------------------------

		protected var _LaunchURL:String;
		protected var _AICCSID:String;
		protected var _AICCURL:String;
		protected var _AICCVersion:String = "3.5";
		protected var _CRLF:String = unescape("%0D%0A"); //"\r"
		
		protected var _isRequestPendingResponse:Boolean = false;
		protected var _pendingRequestType:String;
		
		
		protected var _CacheLessonStatus:String;
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
		
		//protected var _ServerWaitTimeMS:int = 3000;
		//protected var _ServerWaitTimer:TimeKeeper;
		
		protected var _lmsCannotConnectSignal:Signal = new Signal();
		protected var _lmsConnectSignal:Signal = new Signal();
		protected var _lmsDisconnectSignal:Signal = new Signal();
		protected var _lmsSuccessSignal:Signal = new Signal(String);
		protected var _lmsFailureSignal:Signal = new Signal(String);
		
		//---------------------------------------------------------------------
		//
		//	GETTERS/SETTERS
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
		/**
		 * Learner's score
		 */
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
		}

		/**
		 * Bookmarked location
		 */
		public function get lastLocation():String
		{
			return _CacheLastLocation;
		}

		public function set lastLocation(value:String):void
		{
			_CacheLastLocation = value;
			
			lastCommand = "Set last location to: " + _CacheLastLocation;
		}

		/**
		 * State data
		 */
		public function get suspendData():String
		{
			return _CacheSuspendData;
		}

		public function set suspendData(value:String):void
		{
			_CacheSuspendData = value;
			
			lastCommand = "Set susspend data to: " + _CacheSuspendData;
		}

		/**
		 * How long as the sesson been established
		 */
		public function get sessionTime():String
		{
			return _CacheSessionTime;
		}

		public function set sessionTime(value:String):void
		{
			_CacheSessionTime = value;
			
			lastCommand = "Set sesstion time to: " + _CacheSessionTime;
		}

		/**
		 * Status of the SCO
		 */
		public function get lessonStatus():String
		{
			return _CacheLessonStatus;
		}

		public function set lessonStatus(value:String):void
		{
			_CacheLessonStatus = convertSCORMLessonStatusToAICCLessonStatus(value);
			
			lastCommand = "Set lesson status to: " + _CacheLessonStatus;
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

		/**
		 * The last operation
		 */
		public function get lastCommand():String
		{
			return _LastCommand;
		}

		public function set lastCommand(value:String):void
		{
			_LastCommand = value;
			Debugger.instance.add("scorm facade, " + _LastCommand);
		}

		/**
		 * Cannot connect to the LMS
		 */
		public function get lmsCannotConnectSignal():Signal
		{
			return _lmsCannotConnectSignal;
		}

		/**
		 * Connected to the LMS
		 */
		public function get lmsConnectSignal():Signal
		{
			return _lmsConnectSignal;
		}

		/**
		 * Disconnected from the LMS
		 */
		public function get lmsDisconnectSignal():Signal
		{
			return _lmsDisconnectSignal;
		}

		/**
		 * The last command was successful
		 */
		public function get lmsSuccessSignal():Signal
		{
			return _lmsSuccessSignal;
		}

		/**
		 * The last command failed
		 */
		public function get lmsFailureSignal():Signal
		{
			return _lmsFailureSignal;
		}

		//---------------------------------------------------------------------
		//
		//	INITIALIZATION
		//
		//---------------------------------------------------------------------

		/**
		 * Constructor
		 */
		
		public function AICCFacade():void {}
		
		/**
		 * Version param should be the launch string
		 * 
		 * Sample launch URL from Docent 6.5
		 * https://sub.domain.com/wb_content/coursecode/lmsdefault.htm?aicc_sid=3032659%2CA001&aicc_url=sub.domain.com%2Fns-bin%2Fdocentnsapi%2Flms%2Capp1%2C2151%2FSQN%3D-76165634%2CCMD%3DGET%2Cfile%3Daicc_catcher.jsm%2CSVR%3Dpldd005.csm.fub.com%3A48673%2CSID%3DPLDD005.CSM.FUB.COM%3A48673-A9CA-2-B1FD32EA-00BDB3E0%2F
		 */
		public function initialize(data:String = undefined):void
		{
			Debugger.instance.add("AICC LMS initializing", this);
			
			_CacheLastLocation = "";
			_CacheSuspendData = "";
			_CacheScore = -1;
			_CacheSessionTime = "00:00:01";
			
			_RetrievedStudentName = "Name,Student";
			_RetrievedStudentID = "xxxxxx";
			
			_SessionTimer = new TimeKeeper("SCORMSessionTimer");
			
			_LMSConnectionActive = false;
			_SuspendLMSCommunication = true;
			
			_LaunchURL = unescape(data);

			Debugger.instance.add("AICC launch url: "+_LaunchURL, this);

			initializeLMS();
		}

//var CRLF:String = unescape("%0D%0A") //"\r"
//var __initialGetParamUn:String = "error=0\r\rerror_text=Successful\r\rversion=2.0\r\raicc_data=\r\r[core]\r\rstudent_id=a340585\r\rstudent_name=Perkins, Matthew\r\rlesson_location=\r\rcredit=C\r\rlesson_status=N,A\r\rscore=\r\rtime=00:00:00\r\rlesson_mode=Normal\r\r[core_lesson]\r\r\r[core_vendor]\r\r\r[student_data]\r\rmastery_score=80\r\rtime_limit_action=\r\rmax_time_allowed=\r\r\r\r&onLoad=[type Function]"
//var __savedGetParamUn:String = "error=0\r\rerror_text=Successful\r\rversion=2.0\r\raicc_data=\r\r[core]\r\rstudent_id=a340585\r\rstudent_name=Perkins, Matthew\r\rlesson_location=5,5\r\rcredit=C\r\rlesson_status=I\r\rscore=10\r\rtime=01:00:00\r\rlesson_mode=Normal\r\r[core_lesson]1,1,1,1,1|1,1,1,1,1\r\r\r[core_vendor]\r\r\r[student_data]\r\rmastery_score=80\r\rtime_limit_action=\r\rmax_time_allowed=\r\r\r\r&onLoad=[type Function]"
//var __initialGetParam:String = "error=0%0D%0Derror%5Ftext%3DSuccessful%0D%0Dversion%3D2%2E0%0D%0Daicc%5Fdata%3D%0D%0D%5Bcore%5D%0D%0Dstudent%5Fid%3Da340585%0D%0Dstudent%5Fname%3DPerkins%2C%20Matthew%0D%0Dlesson%5Flocation%3D%0D%0Dcredit%3DC%0D%0Dlesson%5Fstatus%3DN%2CA%0D%0Dscore%3D%0D%0Dtime%3D00%3A00%3A00%0D%0Dlesson%5Fmode%3DNormal%0D%0D%5Bcore%5Flesson%5D%0D%0D%0D%5Bcore%5Fvendor%5D%0D%0D%0D%5Bstudent%5Fdata%5D%0D%0Dmastery%5Fscore%3D80%0D%0Dtime%5Flimit%5Faction%3D%0D%0Dmax%5Ftime%5Fallowed%3D%0D%0D%0D%0D%26onLoad%3D%5Btype%20Function%5D"
//var __savedGetParam:String = "error=0%0D%0Derror%5Ftext%3DSuccessful%0D%0Dversion%3D2%2E0%0D%0Daicc%5Fdata%3D%0D%0D%5Bcore%5D%0D%0Dstudent%5Fid%3Da340585%0D%0Dstudent%5Fname%3DPerkins%2C%20Matthew%0D%0Dlesson%5Flocation%3D5%2C5%0D%0Dcredit%3DC%0D%0Dlesson%5Fstatus%3DI%0D%0Dscore%3D10%0D%0Dtime%3D01%3A00%3A00%0D%0Dlesson%5Fmode%3DNormal%0D%0D%5Bcore%5Flesson%5D%0D1%2C1%2C1%2C1%2C1%7C1%2C1%2C1%2C1%2C1%0D%0D%0D%5Bcore%5Fvendor%5D%0D%0D%0D%5Bstudent%5Fdata%5D%0D%0Dmastery%5Fscore%3D80%0D%0Dtime%5Flimit%5Faction%3D%0D%0Dmax%5Ftime%5Fallowed%3D%0D%0D%0D%0D%26onLoad%3D%5Btype%20Function%5D"
//var __savedGetParam2:String ="error=0%0D%0Aerror%5Ftext%3DSuccessful%0D%0Aversion%3D2%2E0%0D%0Aaicc%5Fdata%3D%0D%0A%5Bcore%5D%0D%0Astudent%5Fid%3Da340585%0D%0Astudent%5Fname%3DPerkins%2C%20Matthew%0D%0Alesson%5Flocation%3D3%2C0%0D%0Acredit%3DC%0D%0Alesson%5Fstatus%3DFailed%0D%0Ascore%3D0%0D%0Atime%3D00%3A01%3A22%0D%0Alesson%5Fmode%3DNormal%0D%0A%5Bcore%5Flesson%5D%0D%0A1%2C1%2C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%2C0%2C0%2C0%7C0%2C0%7C0%2C0%0D%0A%5Bcore%5Fvendor%5D%0D%0A%0D%0A%5Bstudent%5Fdata%5D%0D%0Amastery%5Fscore%3D80%0D%0Atime%5Flimit%5Faction%3D%0D%0Amax%5Ftime%5Fallowed%3D%0D%0A%0D%0A%0A&onLoad=%5Btype%20Function%5D"
//parseGetParamData("error=0%0D%0Aerror%5Ftext%3DSuccessful%0D%0Aversion%3D2%2E0%0D%0Aaicc%5Fdata%3D%0D%0A%5Bcore%5D%0D%0Astudent%5Fid%3Da340585%0D%0Astudent%5Fname%3DPerkins%2C%20Matthew%0D%0Alesson%5Flocation%3D0%2C2%0D%0Acredit%3DC%0D%0Alesson%5Fstatus%3DFailed%0D%0Ascore%3D0%0D%0Atime%3D00%3A00%3A31%0D%0Alesson%5Fmode%3DNormal%0D%0A%5Bcore%5Flesson%5D%0D%0A1%2C1%2C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%2C0%2C0%2C0%7C0%2C0%7C0%2C0%0D%0A%5Bcore%5Fvendor%5D%0D%0A%0D%0A%5Bstudent%5Fdata%5D%0D%0Amastery%5Fscore%3D80%0D%0Atime%5Flimit%5Faction%3D%0D%0Amax%5Ftime%5Fallowed%3D%0D%0A%0D%0A%0A&onLoad=%5Btype%20Function%5D")		
//protected static var __initialGetParam	:String = ""	//"error=0%0D%0Derror%5Ftext%3DSuccessful%0D%0Dversion%3D2%2E0%0D%0Daicc%5Fdata%3D%0D%0D%5Bcore%5D%0D%0Dstudent%5Fid%3Da340585%0D%0Dstudent%5Fname%3DPerkins%2C%20Matthew%0D%0Dlesson%5Flocation%3D%0D%0Dcredit%3DC%0D%0Dlesson%5Fstatus%3DN%2CA%0D%0Dscore%3D%0D%0Dtime%3D00%3A00%3A00%0D%0Dlesson%5Fmode%3DNormal%0D%0D%5Bcore%5Flesson%5D%0D%0D%0D%5Bcore%5Fvendor%5D%0D%0D%0D%5Bstudent%5Fdata%5D%0D%0Dmastery%5Fscore%3D80%0D%0Dtime%5Flimit%5Faction%3D%0D%0Dmax%5Ftime%5Fallowed%3D%0D%0D%0D%0D%26onLoad%3D%5Btype%20Function%5D"
//protected static var __savedGetParam		:String = ""	//"error=0%0D%0Aerror%5Ftext%3DSuccessful%0D%0Aversion%3D2%2E0%0D%0Aaicc%5Fdata%3D%0D%0A%5Bcore%5D%0D%0Astudent%5Fid%3Da340585%0D%0Astudent%5Fname%3DPerkins%2C%20Matthew%0D%0Alesson%5Flocation%3D0%2C2%0D%0Acredit%3DC%0D%0Alesson%5Fstatus%3DI%0D%0Ascore%3D%0D%0Atime%3D00%3A01%3A21%0D%0Alesson%5Fmode%3DNormal%0D%0A%5Bcore%5Flesson%5D%0D%0A1%2C1%2C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%7C0%2C0%2C0%2C0%2C0%2C0%2C0%7C0%2C0%7C0%2C0%0D%0A%5Bcore%5Fvendor%5D%0D%0A%0D%0A%5Bstudent%5Fdata%5D%0D%0Amastery%5Fscore%3D80%0D%0Atime%5Flimit%5Faction%3D%0D%0Amax%5Ftime%5Fallowed%3D%0D%0A%0D%0A%0A&onLoad=%5Btype%20Function%5D"


		protected function initializeLMS():void
		{
			
			_AICCURL = getAICCURL();
			_AICCSID = getAICCSID();

			Debugger.instance.add("AICC url: "+_AICCURL, this);
			Debugger.instance.add("AICC sid: "+_AICCSID, this);
			
			// If there is an error sending the GetParam request, the lmsCannotConnectSignal will dispatch
			sendGetParamRequest();
		}

		//---------------------------------------------------------------------
		//
		//	AICC COMMANDS
		//
		//---------------------------------------------------------------------
		
		public function get AICCURL():String 
		{
			return _AICCURL;
		}
		public function get AICCSID():String
		{
			return _AICCSID;
		}
		
		/**
		 * Convert SCORM lesson status to AICC lesson status
		 */
		protected function convertSCORMLessonStatusToAICCLessonStatus(status:String):String
		{
			if(status == SCOStatus.INCOMPLETE) return AUStatus.INCOMPLETE;
			if(status == SCOStatus.COMPLETE) return AUStatus.COMPLETE;
			if(status == SCOStatus.PASS) return AUStatus.PASS;
			if(status == SCOStatus.FAIL) return AUStatus.FAIL;
			return status;
		}
		
		/**
		 * Gets the data string for a put param post
		 */
		protected function getPutParamData():String {
			// if the course is complete or incomplete, don't pass a score
			var auScore:String = (lessonStatus == AUStatus.COMPLETE || lessonStatus == AUStatus.INCOMPLETE) ? "" : String(score); 
			
			var data:String = "[core]\r";
			data += "lesson_location="+lastLocation+"\r";
			data += "lesson_status="+lessonStatus+"\r";
			data += "score="+ auScore +"\r";
			data += "time="+ getSessionTime() +"\r";
			data += "[core_lesson]\r";
			data += suspendData;
			return data;
		}
		
		protected function sendGetParamRequest():void 
		{
			sendRequest(AICCCommands.GET_PARAM, URLRequestMethod.GET, "");
		}
		
		protected function handleGetParamResult(dataResult:*):void 
		{
			Debugger.instance.add("Handle GET param: "+dataResult, this);
			
			_LMSConnectionActive = true;
			_SuspendLMSCommunication = false;
			
			_lmsConnectSignal.dispatch();
		}
		
		protected function sendPutParamRequest():void 
		{
			sendRequest(AICCCommands.PUT_PARAM, URLRequestMethod.POST, getPutParamData());
		}
		
		protected function handlePutParamResult(dataResult:*):void 
		{
			Debugger.instance.add("Handle PUT param: "+dataResult, this);
			
			sendExitAURequest();
		}
		
		/**
		 * NOT IMPLEMENTED
		 */
		protected function sendPutInteractionsRequest():void
		{
			sendRequest(AICCCommands.PUT_INTERACTIONS, URLRequestMethod.POST, "");

			/* SAMPLE DATA
			var t:String = '"course_id","student_id","lesson_id","date","time","interaction_id","objective_id","type_interaction","correct_response","student_response","result","weighting","latency"'
			t += '"'+o.courseid+'","'+o.studentid+'","'+o.lessonid+'","'+o.date+'","'+o.time+'","'+o.id+'","'+o.objectiveid+'","'+o.type+'","'+o.correct_response+'","'+o.student_response+'","'+o.result+'","'+o.weighting+'","'+o.latency+'"'
			*/
		}
		
		protected function handlePutInteractionsResult(dataResult:*):void 
		{
			Debugger.instance.add("Handle PUT interactions: "+dataResult, this);
		}
		
		protected function sendExitAURequest():void 
		{
			sendRequest(AICCCommands.EXITAU, URLRequestMethod.POST, "");
		}
		
		protected function handleExitAUResult(dataResult:*):void 
		{
			Debugger.instance.add("Handle EXIT au: "+dataResult, this);
			_lmsDisconnectSignal.dispatch();
			
			/*recvParamData = recLvObj
			var datatemp:String = "Data from LMS (exitau):\n"+recLvObj+"\n\n"
			_root.aiccdebug_txt.text += datatemp
			if(s) fscommand("CloseWindows")*/
		}

		//---------------------------------------------------------------------
		//
		//	SERVER FUNCTIONS
		//
		//---------------------------------------------------------------------

		/**
		 * Sends the request to the server 
		 * 
		 * Based on
		 * http://snipplr.com/view/4487/as3-sending-data-using-post/
		 */
		protected function sendRequest(requestType:String, requestMethod:String, aiccData:String):void
		{
			Debugger.instance.add("AICC REQUEST type: "+requestType+", method: "+requestMethod+", data: "+aiccData, this);

			if(_isRequestPendingResponse)
			{
				Debugger.instance.add("Warning, request pending: "+_pendingRequestType, this);
			}

			_isRequestPendingResponse = true;
			_pendingRequestType = requestType;
			
			var request:URLRequest = new URLRequest(_AICCURL);
			request.contentType = "text/xml"; // don't know if this is the correct type
			request.data = createURLVariableInstance(aiccData, requestType);
			request.method = requestMethod;
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.VARIABLES; // should this be text or variables?
			
			loader.addEventListener(Event.COMPLETE, onRequestComplete);
			loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, onRequestHTTPStatus);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onRequestSecurityError);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onRequestIOError);
			
			try
			{
			   loader.load(request);
			}
			catch (error:ArgumentError)
			{
			   Debugger.instance.add("ArgumentError occurred when sending the request.", this);
			   clearRequestQueueDispatchFailure();
			}
			catch (error:SecurityError)
			{
			   Debugger.instance.add("SecurityError occurred when sending the request.", this);
			   clearRequestQueueDispatchFailure();
			}
		}

		/**
		 * Creates the URLVariable instance to use for sending all of the server requests
		 */
		protected function createURLVariableInstance(aiccData:String, aiccCommand:String):URLVariables
		{
			var variables:URLVariables = new URLVariables();
			variables.session_id = HTMLContainerUtils.URLEncodeString(_AICCSID);
			variables.version = _AICCVersion;
			variables.command = HTMLContainerUtils.URLEncodeString(aiccCommand);
			variables.aicc_data = HTMLContainerUtils.URLEncodeString(aiccData);
			return variables;
		}

		protected function onRequestHTTPStatus(event:HTTPStatusEvent):void
		{
			Debugger.instance.add("Request HTTP Status event type: "+event.type+", status: "+event.status, this);
		}

		protected function onRequestIOError(event:IOErrorEvent):void
		{
			Debugger.instance.add("IO Error occurred when sending the request.", this);
			clearRequestQueueDispatchFailure();
		}

		protected function onRequestSecurityError(event:SecurityErrorEvent):void
		{
			 Debugger.instance.add("SecurityError(2) occurred when sending the request.", this);
			 clearRequestQueueDispatchFailure();
		}

		/**
		 * Data returned from the request
		 */
		protected function onRequestComplete(event:Event):void
		{
			Debugger.instance.add("Request completed", this);
			
			var loader:URLLoader = URLLoader(event.target);
			
			if(_pendingRequestType == AICCCommands.GET_PARAM) handleGetParamResult(loader.data);
			if(_pendingRequestType == AICCCommands.PUT_PARAM) handlePutParamResult(loader.data);
			if(_pendingRequestType == AICCCommands.PUT_INTERACTIONS) handlePutInteractionsResult(loader.data);
			if(_pendingRequestType == AICCCommands.EXITAU) handleExitAUResult(loader.data);
			
			clearRequestQueueDispatchSuccess();
		}

		protected function clearRequestQueueDispatchSuccess():void
		{
			var theRequestWas:String = _pendingRequestType;
			clearRequestPendingVars();
			_lmsSuccessSignal.dispatch(theRequestWas);
		}

		protected function clearRequestQueueDispatchFailure():void
		{
			var theRequestWas:String = _pendingRequestType;
			clearRequestPendingVars();
			
			// If there was a failure initializing the connection to the LMS then continue with the course
			if(theRequestWas == AICCCommands.GET_PARAM)
			{
				_lmsCannotConnectSignal.dispatch();
			}
			
			_lmsFailureSignal.dispatch(theRequestWas);
		}

		protected function clearRequestPendingVars():void
		{
			_isRequestPendingResponse = false;
			_pendingRequestType = "";
		}
		
		protected function processServerErrorCode(serverResult:String):void
		{
			//var hacp_buffer:String = unescape(String(recLvObj)).toUpperCase()
			//var hacp_error:int = int(hacp_buffer.substr(hacp_buffer.indexOf("ERROR=")+6, 1))
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
		public function getSessionTime():String
		{
			return _SessionTimer.elapsedTimeFormattedHHMMSS();
		}

		/**
		 * Stops the session timer
		 */
		public function stopSessionTimer():void
		{
			if(!_SessionTimer.isRunning) return;
			
			sessionTime = getSessionTime();
			_SessionTimer.stop();
		}

		//---------------------------------------------------------------------
		//
		//	STATUS
		//
		//---------------------------------------------------------------------

		/**
		 * Set the lesson status to incomplete
		 * @param	f	If true, stop the time
		 */
		public function setStatusIncomplete():void
		{
			lessonStatus = AUStatus.INCOMPLETE;
		}

		/**
		 * Set the lesson status to completed
		 */
		public function setStatusComplete():void
		{
			stopSessionTimer();
			lessonStatus = AUStatus.COMPLETE;
		}

		/**
		 * Set the lesson status to pass
		 */
		public function setStatusPass():void
		{
			stopSessionTimer();
			lessonStatus = AUStatus.PASS;
		}

		/**
		 * Set the lesson status to fail
		 */
		public function setStatusFail():void
		{
			stopSessionTimer();
			lessonStatus = AUStatus.FAIL;
		}

		//---------------------------------------------------------------------
		//
		//	COMMIT/DISCONNECT
		//
		//---------------------------------------------------------------------

		public function commit():void
		{
			// not implemented in AICC
		}

		/**
		 * Disconnect from the LMS and end the session. 
		 */
		public function disconnect():void
		{
			//if (!_LMSConnectionActive) return;
			
			Debugger.instance.add("scorm facade, disconnecting");
			
			//sendExitAURequest();
			sendPutParamRequest();
		}

		
		//---------------------------------------------------------------------
		//
		//	UTILITY
		//
		//---------------------------------------------------------------------

		/**
		 * Gets the AICC SID from the launch URL
		 */
		protected function getAICCSID():String
		{
			return HTMLContainerUtils.getQueryStringValue("aicc_sid", _LaunchURL.toLowerCase());
		}

		/**
		 * Gets the AICC URL from the launch URL
		 * Fix for some LMS' - if the protocol is NOT passed as part of the AICC_URL, add it based on the launch URL
		 */
		protected function getAICCURL():String
		{
			var aiccurl:String = HTMLContainerUtils.getQueryStringValue("aicc_url", _LaunchURL.toLowerCase());
			if(aiccurl.toLowerCase().indexOf("http") == 0) return aiccurl;
			return getAICCProtocolFromLaunchURL() + aiccurl;
		}

		/**
		 * Determines what the communication protocol should be based on the AICC url or launch url
		 */
		protected function getAICCProtocolFromLaunchURL():String
		{
			return HTMLContainerUtils.getURLProtocol(_LaunchURL.toLowerCase());
		}

		/**
		 * Get launch data
		 */
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

		/**
		 * Start a timer to trap server timeouts to prevent app from locking up
		 */
		/*protected function startServerWaitTimer():void
		{
			if(!_ServerWaitTimer)
			{
				_ServerWaitTimer = new TimeKeeper("_aicc_server_wait_timer", _ServerWaitTimeMS);
			}
			
			stopServerWaitTimer();
			
			_ServerWaitTimer.addEventListener(TimeKeeper.TIMEUP, onServerWaitTimeOut);
			_ServerWaitTimer.start();
		}*/

		/**
		 * Handled a time out event
		 */
		/*protected function onServerWaitTimeOut(event:TimeKeeper):void
		{
			stopServerWaitTimer();
			
			Debugger.instance.add("AICC Server TIME OUT!", this);
		}*/

		/**
		 * Stop the timer
		 */
		/*protected function stopServerWaitTimer():void
		{
			_ServerWaitTimer.stop();
			_ServerWaitTimer.removeEventListener(TimeKeeper.TIMEUP, onServerWaitTimeOut);
		}*/
		
	}
}
