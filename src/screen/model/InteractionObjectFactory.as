package screen.model
{
	import com.nudoru.lms.scorm.SCORMDataTypes;
	import com.nudoru.lms.scorm.InteractionResult;
	import com.nudoru.lms.scorm.InteractionObject;
	import com.nudoru.lms.scorm.InteractionType;

	/**
	 * @author Matt Perkins
	 */
	public class InteractionObjectFactory implements IInteractionObjectFactory
	{
		private var _model:IQuestionModel;
		private var _LetterList:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];

		public function InteractionObjectFactory(model:IQuestionModel):void
		{
			_model = model;
		}

		/**
		 * Create a SCORM 2004 standard Interaction Object for the answered state of the question
		 * MATCHING types include all drag and drop interactions
		 * 
		 * refer to SCORM 2004 RTE 4.2.9.1 for Correct Response
		 * refer to SCORM 2004 RTE 4.2.9.2 for Learner Response
		 */
		public function create():InteractionObject
		{
			var iObj:InteractionObject = new InteractionObject();
			iObj.prompt = _model.prompt.length ? _model.prompt : _model.text;
			iObj.id = _model.id;
			iObj.type = _model.type;
			iObj.objectives = [];
			iObj.correctResponses = getCorrectResponsePattern();
			iObj.learnerResponse = getLearnerResponsePattern();

			if(_model.isCorrect()) iObj.result = InteractionResult.CORRECT;
			else iObj.result = InteractionResult.INCORRECT;

			var t:Array = _model.latencyTimer.elapsedTimeFormattedHHMMSS().split(":");
			iObj.latency = SCORMDataTypes.toTimeIntervalSecond10(int(t[0]), int(t[1]), int(t[2]));

			iObj.weighting = 1;
			iObj.description = "";

			// trace(iObj);

			return iObj;
		}

		/**
		 * Returns the correct response pattern
		 */
		public function getCorrectResponsePattern():Array
		{
			switch(_model.type)
			{
				case InteractionType.CHOICE:
					return getCorrectResponsePatternForChoice();
					break;
				case InteractionType.MATCHING:
					return getCorrectResponsePatternForMatching();
					break;
			}
			return [];
		}

		/**
		 * Returns the state in which the learner answered the interaction
		 */
		public function getLearnerResponsePattern():String
		{
			switch(_model.type)
			{
				case InteractionType.CHOICE:
					return getLearnerResponsePatternForChoice();
					break;
				case InteractionType.MATCHING:
					return getLearnerResponsePatternForMatching();
					break;
			}
			return "";
		}

		// will only have 1 possible correct pattern
		// to be standard, must use text of choice not index
		private function getCorrectResponsePatternForChoice():Array
		{
			var containerArray:Array = new Array();
			var pattern:String = "";
			for(var i:int = 0; i < _model.choices.length; i++)
			{
				if(_model.choices[i].correct)
				{
					pattern += String(i);
					if(i < _model.choices.length - 2) pattern += ",";
				}
			}
			containerArray.push(pattern);
			return containerArray;
		}

		// to be standard, must use text of choice not index
		private function getLearnerResponsePatternForChoice():String
		{
			var pattern:String = "";
			for(var i:int = 0; i < _model.choices.length; i++)
			{
				if(_model.choices[i].selected)
				{
					pattern += String(i);
					pattern += ",";
				}
			}
			// trim the comma
			pattern = pattern.substr(0, pattern.length - 1);
			return pattern;
		}

		// will only have 1 possible correct pattern
		// to be standard, must use text of choice not index
		private function getCorrectResponsePatternForMatching():Array
		{
			var containerArray:Array = new Array();
			var pattern:String = "";
			for(var i:int = 0; i < _model.choices.length; i++)
			{
				// In Ramen - different for sorting
				// pattern += String(i+1)+"[.]"+_LetterList[getMatchIndexForChoice(i)];
				pattern += String(i + 1) + "[.]" + _LetterList[i];
				if(i < _model.choices.length - 1) pattern += "[,]";
			}
			containerArray.push(pattern);
			return containerArray;
		}

		// to be standard, must use text of choice not index
		private function getLearnerResponsePatternForMatching():String
		{
			var pattern:String = "";
			for(var i:int = 0; i < _model.choices.length; i++)
			{
				pattern += String(i + 1) + "[.]" + _LetterList[_model.choices[i].onMatchIndex];
				// need to get the index of the match
				if(i < _model.choices.length - 1) pattern += "[,]";
			}
			return pattern;
		}
	}
}
