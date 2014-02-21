package screen.model
{
	import com.nudoru.utilities.ArrayUtilities;
	import com.nudoru.debug.Debugger;
	import com.nudoru.utilities.TimeKeeper;

	import flash.geom.Point;
	import flash.display.Sprite;

	import com.nudoru.lms.scorm.*;

	/**
	 * Question model
	 * 
	 * @author Matt Perkins
	 */
	public class QuestionModel extends AbstractScreenModel implements IQuestionModel
	{
		// ---------------------------------------------------------------------
		//
		// VARIABLES
		//
		// ---------------------------------------------------------------------
		private var _choices:Vector.<QuestionChoiceModel>;
		private var _currentTry:int = 0;
		private var _LetterList:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];

		private var _LatencyTimer:TimeKeeper;
		private var _InteractionObjectFactory:IInteractionObjectFactory;

		
		// define subtypes of the standard SCORM types
		public static const SUBTYPE_SORTING:String = "sorting";

		// ---------------------------------------------------------------------
		//
		// GETTER/SETTERS
		//
		// ---------------------------------------------------------------------
		public function get numItems():int
		{
			return _choices.length;
		}

		public function get prompt():String
		{
			return String(_xml.prompt);
		}

		public function get choices():Vector.<QuestionChoiceModel>
		{
			return _choices;
		}

		/**
		 * Valid question types according to the SCORM 2004 model
		 */
		override public function get type():String
		{
			return String(_xml.settings.questiontype);
		}

		public function get subType():String
		{
			return String(_xml.settings.questiontype.@sub);
		}

		/**
		 * Returns the number of tries as specified in the XML. If none default to 2
		 */
		public function get numTries():int
		{
			// is it specified in XML? if not default to 2
			var tries:int = int(_xml.settings.attemps) ? int(_xml.settings.attemps) : 2;
			// is it a choice type with 2 or less? then 1 try
			if((type == InteractionType.CHOICE || type == InteractionType.TRUE_FALSE) && numItems < 3) tries = 1;
			return tries;
		}

		/**
		 * Allow the interaction to be reanswered when you come back to it after it's been answered previously
		 * Default to true
		 */
		public function get allowReanswerOnReturn():Boolean
		{
			if(_xml.settings.allowreanswer == "false") return false;
			return true;
		}

		public function get forceCA():Boolean
		{
			return _xml.settings.force == "true";
		}

		public function get randomizeChoices():Boolean
		{
			return _xml.settings.randomizechoices == "true";
		}

		public function get randomizeMatches():Boolean
		{
			return _xml.settings.randomizematches == "true";
		}

		public function get feedback():String
		{
			return String(_xml.feedback);
		}

		public function get wafeedback():String
		{
			return String(_xml.wa);
		}

		public function get wa2feedback():String
		{
			return String(_xml.wa2);
		}

		public function get cafeedback():String
		{
			return String(_xml.ca);
		}

		public function get singleSelect():Boolean
		{
			// filter out nonchoice types
			if(type != InteractionType.CHOICE && type != InteractionType.TRUE_FALSE) return false;
			if(getNumCorrectChoices() > 1) return false;
			return true;
		}

		public function get currentTry():int
		{
			return _currentTry;
		}

		public function set currentTry(value:int):void
		{
			_currentTry = value;
		}

		public function get latencyTimer():TimeKeeper
		{
			return _LatencyTimer;
		}

		public function get latency():String
		{
			if(_LatencyTimer) return _LatencyTimer.elapsedTimeFormattedHHMMSS();
			return "00:00:00";
		}

		// ---------------------------------------------------------------------
		//
		// INITIALIZE
		//
		// ---------------------------------------------------------------------

		public function QuestionModel(data:XML):void
		{
			super(data);

			_InteractionObjectFactory = new InteractionObjectFactory(this);

			_choices = new Vector.<QuestionChoiceModel>();

			for(var i:int = 0, len:int = _xml.choice.length(); i < len; i++)
			{
				_choices.push(new QuestionChoiceModel(_xml.choice[i]));
			}
		}

		/**
		 * Starts the latency timer
		 */
		public function startTimer():void
		{
			if(! _LatencyTimer)
			{
				_LatencyTimer = new TimeKeeper("screen_latency_timer");
			}
			_LatencyTimer.start();
		}

		/**
		 * Stops the latency timer
		 */
		public function stopTimer():void
		{
			if(_LatencyTimer) _LatencyTimer.stop();
		}

		// ---------------------------------------------------------------------
		//
		// JUDGEMENT/FEEDBACK
		//
		// ---------------------------------------------------------------------
		/**
		 * Is the question correct according to the type?
		 */
		public function isCorrect():Boolean
		{
			switch (type)
			{
				case InteractionType.CHOICE:
					return isChoiceQuestionCorrect();
					break;
				case InteractionType.MATCHING:
					return isMatchingQuestionCorrect();
					break;
				default:
					trace("Question.isCorrect can't judge question type: " + type);
			}
			return false;
		}

		/**
		 * Is a type "choice" question correct
		 */
		private function isChoiceQuestionCorrect():Boolean
		{
			for(var i:int = 0, len:int = numItems; i < len; i++)
			{
				if(! getIsChoiceAnsweredCorrectly(i)) return false;
			}
			return true;
		}

		/**
		 * Is the choice marked as correct in XML?
		 */
		public function getIsChoiceCorrect(choice:int):Boolean
		{
			return _choices[choice].correct;
		}

		/**
		 * Is the choice both selected and correct OR unselected and uncorrect
		 */
		public function getIsChoiceAnsweredCorrectly(choice:int):Boolean
		{
			return _choices[choice].isChoiceCorrect();
		}

		/**
		 * Is a type "matching" question correct?
		 */
		private function isMatchingQuestionCorrect():Boolean
		{
			if(subType == QuestionModel.SUBTYPE_SORTING) return isSortingQuestionCorrect();
			
			for(var i:int = 0, len:int = numItems; i < len; i++)
			{
				if(! isChoiceOnMatch(i)) return false;
			}
			return true;
		}


		/**
		 * Test if the text of the match index that the choice is on is the same as the text of it's correct match 
		 */
		public function getIsChoiceOnAValidSortingMatch(choice:int):Boolean
		{
			var correctMatchString:String = getChoiceMatchText(choice);
			var matchOnString:String = getChoiceMatchText(getChoiceOnMatch(choice));
			if(correctMatchString == matchOnString) return true;
			return false;
		}

		private function isSortingQuestionCorrect():Boolean
		{
			for(var i:int = 0, len:int = numItems; i < len; i++)
			{
				if(!getIsChoiceOnAValidSortingMatch(i)) return false;
			}
			return true;
		}

		/**
		 * Get the proper feedback for the question either on the choice or question level
		 */
		public function getFeedback():String
		{
			var correct:Boolean = isCorrect();
			var selectedChoice:int = getFirstSelectedChoice();
			var anotherTry:Boolean = hasAnotherTry();

			// get choice level feedback IF: correct and no more tries, it's single select, a choice IS selected it has feedback
			if((correct || ! anotherTry) && singleSelect && isAnyChoiceSelected() && getChoiceByIdx(selectedChoice).feedback) return getChoiceByIdx(selectedChoice).feedback;

			// correct answer
			if(correct)
			{
				if(cafeedback) return cafeedback;
			}

			// out of tries and incorrectly answered
			if(! anotherTry && ! correct)
			{
				if(wa2feedback) return wa2feedback;
			}

			// default incorrect feedback and not correct
			if(wafeedback && ! correct) return wafeedback;

			return "NO FEEDBACK FOUND";
		}

		/**
		 * Increments the number of tries and return true if another one is allowed, false if not
		 */
		public function nextTry():Boolean
		{
			_currentTry++;
			return hasAnotherTry();
		}

		/**
		 * Is there another attempt left?
		 */
		public function hasAnotherTry():Boolean
		{
			if(isCorrect()) return false;
			if(forceCA) return true;
			if(_currentTry < numTries) return true;
			return false;
		}

		// ---------------------------------------------------------------------
		//
		// GET CHOICE DATA - COMMON FOR ALL
		//
		// ---------------------------------------------------------------------
		/**
		 * Returns a question choice by index in the array
		 */
		public function getChoiceByIdx(i:int):QuestionChoiceModel
		{
			return _choices[i];
		}

		/**
		 * Returns a question choice's index in the array by its ID
		 */
		public function getChoiceIdxByID(id:String):int
		{
			for(var i:int = 0, len:int = _choices.length; i < len; i++)
			{
				if(_choices[i].id == id) return i;
			}
			return -1;
		}

		/**
		 * Returns a question choice by it's ID
		 */
		public function getChoiceByID(id:String):QuestionChoiceModel
		{
			var idx:int = getChoiceIdxByID(id);
			if(idx > -1) return _choices[idx];
			return undefined;
		}

		/**
		 * Set the sprite of the choice
		 */
		public function setChoiceSprite(choice:int, sprite:Sprite):void
		{
			_choices[choice].choiceSprite = sprite;
		}

		/**
		 * Get the sprite of the choice
		 */
		public function getChoiceSprite(choice:int):Object
		{
			return _choices[choice].choiceSprite;
		}

		/**
		 * Get the sprite of the choice
		 */
		public function getChoiceMatchText(choice:int):String
		{
			return _choices[choice].match;
		}

		/**
		 * Gets the index of a letter. A = 0, Z = 25
		 */
		public function getLetterIndex(letter:String):int
		{
			var letterLower:String = letter.toLowerCase();
			for(var i:int = 0,len:int = _LetterList.length;i < len;i++)
			{
				if(letterLower == _LetterList[i]) return i;
			}
			return 0;
		}

		// ---------------------------------------------------------------------
		//
		// MC COMMON
		//
		// ---------------------------------------------------------------------
		/**
		 * Is the choice selected?
		 */
		public function getChoiceSelected(choice:int):Boolean
		{
			return _choices[choice].selected;
		}

		/**
		 * Set the choice to the specified selected state
		 */
		public function setChoiceSelected(choice:int, select:Boolean = true):void
		{
			_choices[choice].selected = select;
		}

		/**
		 * Clear selection of all choices
		 */
		public function deselectAllChoices():void
		{
			for(var i:int = 0, len:int = _choices.length; i < len; i++)
			{
				setChoiceSelected(i, false);
			}
		}

		/**
		 * True if any choices are selected
		 */
		public function isAnyChoiceSelected():Boolean
		{
			for(var i:int = 0, len:int = _choices.length; i < len; i++)
			{
				if(getChoiceSelected(i)) return true;
			}
			return false;
		}

		/**
		 * Number of correct choices
		 */
		public function getNumCorrectChoices():int
		{
			var cntr:int = 0;
			for(var i:int = 0, len:int = numItems; i < len; i++)
			{
				if(_choices[i].correct) cntr++;
			}
			return cntr;
		}

		/**
		 * The first correct choice index. -1 if none
		 */
		public function getFirstCorrectChoice():int
		{
			for(var i:int = 0, len:int = numItems; i < len; i++)
			{
				if(_choices[i].correct) return i;
			}
			return -1;
		}

		/**
		 * The first selected choice index. -1 if nonw
		 */
		public function getFirstSelectedChoice():int
		{
			for(var i:int = 0, len:int = numItems; i < len; i++)
			{
				if(_choices[i].selected) return i;
			}
			return -1;
		}

		// ---------------------------------------------------------------------
		//
		// SORTING COMMON
		//
		// ---------------------------------------------------------------------
		
		public function getAllUniqueMatchNames():Array
		{
			var matches:Array = [];
			for(var i:int,len:int=numItems; i<len; i++)
			{
				ArrayUtilities.addUniqueValue(matches, choices[i].match);
			}
			return matches;
		}
		
		public function getNumberOfMatchesWithMatchText(text:String):int
		{
			var count:int;
			for(var i:int,len:int=numItems; i<len; i++)
			{
				if(choices[i].match == text) count++;
			}
			return count;
		}
		
		// ---------------------------------------------------------------------
		//
		// MATCHING COMMON
		//
		// ---------------------------------------------------------------------
		
		/**
		 * Gets the match sprite of a choice by the index of a choice
		 */
		public function getMatchSpriteByIndex(match:int):Sprite
		{
			return _choices[match].matchSprite;
		}

		/**
		 * Sets a choice to be on a match item
		 */
		public function setChoiceOnMatch(choice:int, onmatch:int):void
		{
			_choices[choice].onMatchIndex = onmatch;
		}

		/**
		 * Gets the match item for a choice
		 */
		public function getChoiceOnMatch(choice:int):int
		{
			return _choices[choice].onMatchIndex;
		}

		/**
		 * Clear match items for all choices
		 */
		public function clearAllChoiceOnMatches():void
		{
			for(var i:int = 0, len:int = numItems;i < len;i++)
			{
				setChoiceOnMatch(i, undefined);
			}
		}

		/**
		 * All all choices assigned to a match?
		 */
		public function areAllChoicesMatched():Boolean
		{
			for(var i:int = 0, len:int = numItems;i < len;i++)
			{
				if(getChoiceOnMatch(i) < 0) return false;
			}
			return true;
		}

		/**
		 * Get any match under a choice
		 * @param	c
		 * @return
		 */
		public function getMatchSpriteUnderChoiceSprite(c:int):Sprite
		{
			for(var i:int = 0, len:int = numItems; i < len; i++)
			{
				var testMatch:Sprite = _choices[i].matchSprite;
				if(doesChoiceHitMatch(c, testMatch)) return testMatch;
			}

			return null;
		}

		/**
		 * Test the match sprite for each choice to determine if the point intersects it
		 */
		public function getMatchSpriteUnderPoint(p:Point):Sprite
		{
			for(var i:int = 0, len:int = numItems; i < len; i++)
			{
				var err:Boolean = false;
				try
				{
					err = _choices[i].matchSprite.hitTestPoint(p.x, p.y);
				}
				catch (e:*)
				{
				}
				if(err) return _choices[i].matchSprite;
			}

			return null;
		}

		/**
		 * Test the mach sprite for each choice and determine if the choice hits it
		 */
		public function getMatchUnderChoiceRefMC(c:int):Sprite
		{
			for(var i:int = 0, len:int = numItems; i < len; i++)
			{
				var err:Boolean = false;
				try
				{
					err = _choices[c].choiceSprite.hitTestObject(_choices[i].matchSprite);
				}
				catch(e:*)
				{
				}
				if(err) return _choices[i].matchSprite;
			}
			return null;
		}

		/**
		 * Is the choice over a match
		 * @param	choice
		 * @param	match
		 * @return
		 */
		public function doesChoiceHitMatch(c:int, match:Sprite):Boolean
		{
			var choice:Sprite = _choices[c].choiceSprite;

			var err:Boolean = false;
			try
			{
				err = choice.hitTestObject(match);
			}
			catch(e:*)
			{
			}
			return err;
		}

		/**
		 * Is the choice on it's correct match?
		 */
		public function isChoiceOnMatch(c:int):Boolean
		{
			return _choices[c].isOnMatch();
		}

		/**
		 * Does the given Point hit the choice's match?
		 */
		public function isChoiceOnMatchPoint(c:int, p:Point):Boolean
		{
			return _choices[c].isOnMatchPoint(p);
		}

		// ---------------------------------------------------------------------
		//
		// INTERACTION OBJECT
		// Data based on SCORM 2004 model
		//
		// ---------------------------------------------------------------------
		/**
		 * Create a SCORM 2004 standard Interaction Object for the answered state of the question
		 * MATCHING types include all drag and drop interactions
		 * 
		 * refer to SCORM 2004 RTE 4.2.9.1 for Correct Response
		 * refer to SCORM 2004 RTE 4.2.9.2 for Learner Response
		 */
		public function createInteractionObject():InteractionObject {
			return _InteractionObjectFactory.create();
		}

		public function getCorrectResponsePattern():Array
		{
			return _InteractionObjectFactory.getCorrectResponsePattern();
		}

		public function getLearnerResponsePattern():String
		{
			return _InteractionObjectFactory.getLearnerResponsePattern();
		}
		
		// ---------------------------------------------------------------------
		//
		// DESTROY
		//
		// ---------------------------------------------------------------------
		public function destroy():void
		{
			if(_LatencyTimer)
			{
				_LatencyTimer.stop();
				_LatencyTimer = undefined;
			}
		}

	}
}