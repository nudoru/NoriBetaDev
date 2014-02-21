package screen.model
{
	import com.nudoru.utilities.TimeKeeper;
	import com.nudoru.lms.scorm.*;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public interface IQuestionModel extends IAbstractScreenModel
	{
		function get numItems():int;
		function get prompt():String;
		function get choices():Vector.<QuestionChoiceModel>;
		function get numTries():int;
		function get allowReanswerOnReturn():Boolean;
		function get forceCA():Boolean;
		function get randomizeChoices():Boolean;
		function get randomizeMatches():Boolean;
		function get feedback():String;
		function get wafeedback():String;
		function get wa2feedback():String;
		function get cafeedback():String;
		function get singleSelect():Boolean;
		function get currentTry():int;
		function set currentTry(value:int):void;
		function get latencyTimer():TimeKeeper;
		function get latency():String;
		
		function startTimer():void;
		function stopTimer():void;
		
		function isCorrect():Boolean;
		function getIsChoiceCorrect(choice:int):Boolean;
		function getIsChoiceAnsweredCorrectly(choice:int):Boolean;
		function getFeedback():String;
		function nextTry():Boolean;
		function hasAnotherTry():Boolean;
		
		function getChoiceByIdx(i:int):QuestionChoiceModel;
		function getChoiceIdxByID(id:String):int;
		function getChoiceByID(id:String):QuestionChoiceModel;
		function setChoiceSprite(choice:int, sprite:Sprite):void;
		function getChoiceSprite(choice:int):Object;
		function getChoiceMatchText(choice:int):String
		
		function getLetterIndex(letter:String):int;
		
		function getChoiceSelected(choice:int):Boolean;
		function setChoiceSelected(choice:int, select:Boolean = true):void;
		function deselectAllChoices():void;
		function isAnyChoiceSelected():Boolean;
		function getNumCorrectChoices():int;
		function getFirstCorrectChoice():int;
		function getFirstSelectedChoice():int;
		
		function getAllUniqueMatchNames():Array;
		function getNumberOfMatchesWithMatchText(text:String):int;
		
		function getMatchSpriteByIndex(match:int):Sprite;
		function setChoiceOnMatch(choice:int, onmatch:int):void;
		function getChoiceOnMatch(choice:int):int;
		function clearAllChoiceOnMatches():void;
		function areAllChoicesMatched():Boolean;
		function getMatchSpriteUnderChoiceSprite(c:int):Sprite;
		function getMatchSpriteUnderPoint(p:Point):Sprite;
		function getMatchUnderChoiceRefMC(c:int):Sprite;
		function doesChoiceHitMatch(c:int, match:Sprite):Boolean;
		function isChoiceOnMatch(c:int):Boolean;
		function isChoiceOnMatchPoint(c:int, p:Point):Boolean;
		
		function createInteractionObject():InteractionObject;
		function getCorrectResponsePattern():Array;
		function getLearnerResponsePattern():String;
		
		function destroy():void;
	}
}