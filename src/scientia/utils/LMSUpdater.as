package scientia.utils
{
	import com.nudoru.debug.Debugger;
	import com.nudoru.lms.scorm.SCOStatus;
	import scientia.model.consts.CompletionCriteria;
	import com.nudoru.lms.ILMSProtocolFacade;
	import scientia.model.IScientiaModel;
	
	/**
	 * Updates the LMS
	 * 
	 * @author Matt Perkins
	 */
	public class LMSUpdater implements ILMSUpdater
	{
		
		private var _model:IScientiaModel;
		private var _LMSProtocol:ILMSProtocolFacade;

		public function get model():IScientiaModel
		{
			return _model;
		}

		[Inject]
		public function set model(value:IScientiaModel):void
		{
			_model = value;
		}

		public function get lmsProtocol():ILMSProtocolFacade
		{
			return _LMSProtocol;
		}
		
		[Inject]
		public function set lmsProtocol(value:ILMSProtocolFacade):void
		{
			_LMSProtocol = value;
		}
		
		public function LMSUpdater():void {}
		
		/**
		 * Update data on the LMS
		 */
		public function update():void
		{
			// get tracking data from the model.
			var scoStatus:String = getSCOStatus();
			var suspendData:String = model.getSuspendData();
			var score:int = model.getCurrentScorePercentage();

			if(lmsProtocol.LMSCommunicationAllowed)
			{
				// prevents the score from recording if it's not the completion criteria
				if(model.configVO.lmsCompletionCriteria != CompletionCriteria.SCORE) score = 0;
				
				lmsProtocol.score = score;
				lmsProtocol.lessonStatus = scoStatus;
				lmsProtocol.suspendData = suspendData;
			}
			
			//trace("SCORE: "+model.getCurrentScorePercentage());
			//trace("SCO STATUS: "+scoStatus);
			//trace("SD: "+suspendData);
		}

		private function getSCOStatus():String
		{
			if(model.isComplete())
			{
				Debugger.instance.add("Course is complete!", this);
				
				if(model.configVO.lmsCompletionCriteria == CompletionCriteria.SCORE)
				{
					if(model.isPassing()) return SCOStatus.PASS;
					else 
					{
						if(!model.configVO.lmsAllowFailingStatus) return SCOStatus.INCOMPLETE;
						return SCOStatus.FAIL;
					}
				}
				
				return SCOStatus.COMPLETE;
			}
			
			return SCOStatus.INCOMPLETE;
		}
		
		/**
		 * Disconnect from the LMS
		 */
		public function disconnect():void
		{
			Debugger.instance.add("DISCONNECTING FROM LMS", this);
			
			/*if(lmsProtocol.LMSCommunicationAllowed)
			{
				lmsProtocol.disconnect();
			}*/
			
			lmsProtocol.disconnect();
		}
	}
}
