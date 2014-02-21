package com.nudoru.lms.lectora
{
	// import com.bac.senkou.utils.Debugger;
	import flash.external.ExternalInterface;

	/**
	 * Communicates with a Lectora course. SWF needs to be embedded in the page
	 * These varialbes need to be in your lectora course
	 * FLVarStudentName
	 * FLVarStudentID
	 * FLVarBookmark
	 * FLVarSuspendData
	 * 
	 * To get the name of an object in Lectora go to File>Preferences then check the “Show HTML-published 
	 * object names in object properties” checkbox. Then double-click an object and its name will be in the 
	 * upper-right corner of the dialogue popup.
	 */
	public class LectoraFacade implements ILectoraFacade
	{
		private var _DebugLog:Array;
		public const SUCCESS:String = "LC_SUCCESS";
		public const INCOMPLETE:String = "incomplete";
		public const COMPLETED:String = "completed";

		public function get debugLog():Array
		{
			return _DebugLog;
		}

		public function get debugLogStr():String
		{
			if (!_DebugLog) return "no debug information";
			var str:String;
			for (var i:int = 0; i < _DebugLog.length; i++)
			{
				str += _DebugLog[i] + "\n";
			}
			return str;
		}

		public function LectoraFacade():void
		{
		}

		private function debug($m:String):void
		{
			if (!_DebugLog) _DebugLog = new Array();
			_DebugLog.push($m);
		}

		private function callExternalFunction($f:String, $p:String = undefined):*
		{
			debug("LC: Calling function '" + $f + "' with param '" + $p + "'");
			if (!ExternalInterface.available) return;
			var data:*;
			try
			{
				data = ExternalInterface.call($f, $p);
			}
			catch (e:SecurityError)
			{
				debug("LC: Security error: '" + e.message + "' When calling: " + $f);
				return null;
			}
			catch (e:Error)
			{
				debug("LC: General error: '" + e.message + "' When calling: " + $f);
				return null;
			}
			debug("LC: SUCCESS, ret: '" + data + "'");
			return data;
		}

		// -simple complicated actions------------------------------------------------------------------------
		// do we need to pass another param for 'true' = bFeedback option
		// looks like it just resets the feedback index and is only used in question pages
		public function navigateToPage($p:String):void
		{
			callExternalFunction("trivExitPage", $p);
		}

		public function navigateToNextPage():void
		{
			callExternalFunction("trivNextPage");
		}

		public function navigateToPreviousPage():void
		{
			callExternalFunction("trivPrevPage");
		}

		public function showButton($b:String):void
		{
			callExternalFunction($b + ".actionShow");
		}

		public function hideButton($b:String):void
		{
			callExternalFunction($b + ".actionHide");
		}

		public function setVariable($var:String, $val:String):void
		{
			callExternalFunction("Var" + $var + ".set", $val);
		}

		public function getVariable($var:String):String
		{
			return callExternalFunction("Var" + $var + ".getValue");
		}

		public function executeAction($a:String):void
		{
			callExternalFunction($a);
		}

		// -Pre defined variables--------------------------------------------------------------------------
		// these should be used over the SCORM Variables
		public function getFLVarStudentName():String
		{
			return getVariable("FLVarStudentName");
		}

		public function getFLVarStudentID():String
		{
			return getVariable("FLVarStudentID");
		}

		public function getFLVarBookmark():String
		{
			return getVariable("FLVarBookmark");
		}

		public function setFLVarBookmark($val:String):void
		{
			setVariable("FLVarBookmark", $val);
		}

		public function getFLVarSuspendData():String
		{
			return getVariable("FLVarSuspendData");
		}

		public function setFLVarSuspendData($val:String):void
		{
			setVariable("FLVarSuspendData", $val);
		}

		// -SCORM vars--------------------------------------------------------------------------------------
		// Cannot access the variables properly? Use custom Lectora variables instead
		/*public function setLMSLessonLocation($val:String):void {
		setVariable("AICC_Lesson_Location", $val);
		}
		public function getLMSLessonLocation():String {
		return getVariable("AICC_Lesson_Location");
		}
		
		public function setLMSLessonStatus($val):void {
		setVariable("AICC_Lesson_Status", $val);
		}
		public function setLMSLessonIncomplete():void {
		setLMSLessonStatus(LectoraConnector.INCOMPLETE);
		}
		public function setLMSLessonComplete():void {
		setLMSLessonStatus(LectoraConnector.COMPLETED);
		}
		public function getLMSLessonStatus():String {
		return getVariable("AICC_Lesson_Status");
		}
		
		public function setLMSScore($val:int):void {
		setVariable("AICC_Score", String($val));
		}
		public function getLMSScore():int {
		return int(getVariable("AICC_Score"));
		}
		
		public function getLMSStudentName():String {
		return getVariable("AICC_Student_Name");
		}
		public function getLMSStudentID():String {
		return getVariable("AICC_Student_ID");
		}*/
		// best not to use the lectora suspend data but create a new variable for the flash
		// LMSGetValue( 'cmi.suspend_data' );
		// LMSSetValue( 'cmi.suspend_data', newData )
		// -more complicated actions------------------------------------------------------------------------
		public function setTextFieldContents($tf:String, $txt:String, $algn:String = "alignleft"):void
		{
			debug("Calling function 'actionChangeContents'");
			if (!ExternalInterface.available) return;
			try
			{
				ExternalInterface.call($tf + ".actionChangeContents", $txt, $algn, "1");
			}
			catch (e:SecurityError)
			{
				debug("Security error: " + e.message + "\nWhen calling: actionChangeContents");
				return;
			}
			catch (e:Error)
			{
				debug("General error: " + e.message + "\nWhen calling: actionChangeContents");
				return;
			}
			debug("SUCCESS");
		}

		public function openPopUpWindow($url:String, $w:int, $h:int, $lft:int = 0, $tp:int = 0, $sb:int = 1, $rz:int = 1, $mb:int = 1, $tb:int = 1, $loc:int = 1, $sts:int = 1):void
		{
			debug("Calling function 'ObjLayerActionGoToNewWindow'");
			if (!ExternalInterface.available) return;
			var parms:String = "width=" + $w + ",height=" + $h + ",left=" + $lft + ",top=" + $tp + ",scrollbars=" + $sb + ",resizable=" + $rz + ",menubar=" + $mb + ",toolbar=" + $tb + ",location=" + $loc + ",status=" + $sts;
			try
			{
				ExternalInterface.call("ObjLayerActionGoToNewWindow", $url, "Trivantis_Popup_Window_" + rnd(0, 1000), parms);
			}
			catch (e:SecurityError)
			{
				debug("Security error: " + e.message + "\nWhen calling: ObjLayerActionGoToNewWindow");
				return;
			}
			catch (e:Error)
			{
				debug("General error: " + e.message + "\nWhen calling: ObjLayerActionGoToNewWindow");
				return;
			}
			debug("SUCCESS");
		}

		public function rnd(min:Number, max:Number):Number
		{
			return min + Math.floor(Math.random() * (max + 1 - min));
		}
	}
}