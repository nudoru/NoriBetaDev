package screen.controller
{
	import com.nudoru.visual.BMUtils;
	import flash.display.MovieClip;
	import screen.model.QuestionModel;
	import flash.geom.Point;
	import com.nudoru.constants.KeyDict;
	import flash.events.FocusEvent;
	import com.nudoru.utilities.MathUtilities;

	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;

	import com.greensock.easing.Back;

	import flash.display.Sprite;

	import com.greensock.easing.Quad;
	import com.greensock.easing.Elastic;
	import com.greensock.TweenMax;

	/**
	 * Common functionality for Matching/DND screens
	 * Type Object is used to be boadly compatible since we're not worried about performance
	 * @author Matt Perkins
	 */
	public class AbstractDNDQuestionScreen extends AbstractQuestionScreen implements IAbstractDNDQuestionScreen
	{
		// ---------------------------------------------------------------------
		//
		// VARIABLES
		//
		// ---------------------------------------------------------------------
		
		protected var _AccessibilityEnabled:Boolean = false;
		protected var _AccSelectedChoice:int = -1;
		protected var _AccAidSprites:Array = [];
		
		protected var _IsDragging:Boolean = false;
		
		protected var _StaticChoiceSprites:Array = [];
		protected var _MatchSprites:Array = [];
		protected var _StaticMatchSprites:Array = [];
		
		// the matches may be randomized - use this instead of the linear counter
		protected var _RndMatchArray:Array = [];

		protected var _ChoiceAndMatchYOffset:int = 0;

		protected var _ChoiceAndMatchBorder:int = 2;
		protected var _ChoiceAndMatchColumnGutter:int = 10;
		protected var _ChoiceColumnX:int = 10;
		protected var _ChoiceColumnY:int = 0;
		protected var _ChoiceColumnHeight:int = 50;
		protected var _ChoiceColumnWidth:int = 340;
		protected var _ChoiceColumnXSpacing:int = 5;
		protected var _ChoiceColumnYSpacing:int = 5;
		protected var _MatchColumnX:int = screenWidth - 425 - 50;
		protected var _MatchColumnY:int = 0;
		protected var _MatchColumnHeight:int = 425;
		protected var _MatchColumnWidth:int = 425;
		protected var _MatchColumnXSpacing:int = 5;
		protected var _MatchColumnYSpacing:int = 5;
		
		protected var _TallestItemHeight:int = 0;
		
		// ---------------------------------------------------------------------
		//
		// INITIALIZE
		//
		// ---------------------------------------------------------------------
		
		public function AbstractDNDQuestionScreen()
		{
			super();
		}

		// ---------------------------------------------------------------------
		//
		// RENDER
		//
		// ---------------------------------------------------------------------
		
		/**
		 * Configures the choice and match columns for a 2 column layout with a big gutter
		 */
		protected function configureNColumnLayout(columns:int, left:int, right:int, gutter:int=0):void
		{
			if(!gutter) gutter = _ChoiceAndMatchColumnGutter;
			
			var availableWidth:int = screenWidth - left - right - (gutter*(columns-1));
			var columnWidth:int = availableWidth/columns;
			var rightSide:int = screenWidth - right;
			
			_ChoiceColumnX = left;
			_ChoiceColumnWidth = columnWidth;
			
			_MatchColumnX = rightSide-columnWidth;
			_MatchColumnWidth = columnWidth;
		}
		
		/**
		 * Configures the choice and match columns for a 2 column layout with a big gutter
		 */
		protected function configureTwoColumnLayout(left:int, right:int, gutter:int=0):void
		{
			if(!gutter) gutter = _ChoiceAndMatchColumnGutter;
			
			var availableWidth:int = screenWidth - left - right - gutter;
			var columnWidth:int = availableWidth/2;
			var rightSide:int = screenWidth - right;
			
			_ChoiceColumnX = left;
			_ChoiceColumnWidth = columnWidth;
			
			_MatchColumnX = rightSide-columnWidth;
			_MatchColumnWidth = columnWidth;
		}
		
		/**
		 * Configures the choice and match columns for a 3 column layout with a big gutter
		 */
		protected function configureThreeColumnLayout(left:int, right:int, gutter:int=0):void
		{
			if(!gutter) gutter = _ChoiceAndMatchColumnGutter;
			
			var availableWidth:int = screenWidth - left - right - (gutter*2);
			var columnWidth:int = availableWidth/3;
			var rightSide:int = screenWidth - right;
			
			_ChoiceColumnX = left;
			_ChoiceColumnWidth = columnWidth;
			
			_MatchColumnX = rightSide-columnWidth;
			_MatchColumnWidth = columnWidth;
		}

		/**
		 * Draws the interaction
		 * MUST OVERRIDE THIS FUNCTION CALL super.renderInteractiveObjects(); so that 
		 * this boilerplate code runs
		 */
		override protected function renderInteractiveObjects():void
		{
			_RndChoicesArray = MathUtilities.createNumArray(_Model.numItems);
			_RndMatchArray = MathUtilities.createNumArray(_Model.numItems);

			if(_Model.randomizeChoices) _RndChoicesArray = MathUtilities.rndNumArray(_Model.numItems, true);
			if(_Model.randomizeMatches) _RndMatchArray = MathUtilities.rndNumArray(_Model.numItems, true);

			// holds all of the question parts
			_IObjectHolder = new Sprite();
			_IObjectHolder.x = 0;
			_IObjectHolder.y = _CTATextTB.y + _CTATextTB.measure().height + screenBorder;

			_InteractionLayer.addChild(_IObjectHolder);
			
			// MUST OVERRIDE THIS FUNCTION AND INLUCDE MORE FUNCTIONALITY BELOW HERE
		}

		/**
		 * Utility - returns the height in pixels of the talled displayobject in an array or vector
		 */
		protected function getHeightOfTallestMCInArray(array:*):int
		{
			var height:int = 0;
			
			for(var i:int, len:int=array.length; i<len; i++)
			{
				if(array[i].height > height) height = array[i].height;		
			}
			
			return height;
		}

		/**
		 * Resize all of the choices to be as tall as the tallest
		 */
		protected function resizeChoicesToTallest():void
		{
			for(var i:int, len:int = _IObjects.length; i < len; i++)
			{
				var choiceItem:MovieClip = _IObjects[i] as MovieClip;
				choiceItem.bg_mc.scaleY = _TallestItemHeight * .01;
				choiceItem.hi_mc.scaleY = choiceItem.bg_mc.scaleY;
				choiceItem.text_txt.y = int((_TallestItemHeight/2)-(choiceItem.text_txt.height/2));
			}
		}

		/**
		 * Revert to an answered state from the response string.
		 * Format is Learner Repsonse SCORM 2004 pattern
		 */
		override protected function restoreQuestionState(responseState:String):void
		{
			// Sample learner response 1[.]b[,]2[.]a
			var learnerRespones:Array = responseState.split("[,]");
			for(var i:int = 0,len:int = learnerRespones.length;i < len;i++)
			{
				var pair:Array = learnerRespones[i].split("[.]");
				var choice:int = int(pair[0]) - 1;
				var match:int = _Model.getLetterIndex(pair[1]);
				alignChoiceToMatchNoRemoval(choice, match);
			}
		}

		// ---------------------------------------------------------------------
		//
		// INTERACTION
		//
		// ---------------------------------------------------------------------
		
		/**
		 * Enable mouse interaction on the interactive object
		 */
		override protected function enableIObject(iobject:*):void
		{
			iobject.buttonMode = true;
			iobject.mouseChildren = false;
			iobject.addEventListener(MouseEvent.ROLL_OVER, onIObjectOver, false, 0, true);
			iobject.addEventListener(MouseEvent.ROLL_OUT, onIObjectOut, false, 0, true);
			iobject.addEventListener(MouseEvent.MOUSE_DOWN, onIObjectDown, false, 0, true);
			iobject.addEventListener(MouseEvent.MOUSE_UP, onIObjectUp, false, 0, true);
			
			// for accessibility
			iobject.addEventListener(FocusEvent.FOCUS_IN, onIObjectFocusIn, false, 0, true);
			iobject.addEventListener(FocusEvent.FOCUS_OUT, onIObjectFocusOut, false, 0, true);
		}

		/**
		 * Choice over
		 * @param	e
		 */
		override protected function onIObjectOver(e:MouseEvent):void
		{
			//e.target.gotoAndStop("over");
			TweenMax.to(e.target.hi_mc, .25, {alpha:.25, ease:Quad.easeOut});
		}

		/**
		 * Choice out
		 * @param	e
		 */
		override protected function onIObjectOut(e:MouseEvent):void
		{
			//e.target.gotoAndStop("up");
			TweenMax.to(e.target.hi_mc, .5, {alpha:0, ease:Quad.easeOut});
		}

		/**
		 * Choice down, start drag
		 * @param	e
		 */
		override protected function onIObjectDown(e:MouseEvent):void
		{
			TweenMax.killTweensOf(e.target);
			hideAccessibilityCues();
			
			// put it on top
			_IObjectHolder.addChild(e.target as DisplayObject);

			e.target.startDrag();

			_IsDragging = true;

			applyDraggingEffect(e.target);

			// draw the line as the dot's dragged around the screen
			e.target.addEventListener(Event.ENTER_FRAME, onIObjectEnterFrame, false, 0, true);
		}

		protected function applyDraggingEffect(choice:Object):void
		{
			BMUtils.applyDropShadowFilter(choice, 10, 45, 0x000000, .5, 10, 1);
		}

		protected function removeDraggingEffect(choice:Object):void
		{
			BMUtils.clearAllFilters(choice);
		}


		/**
		 * Choice up, stop drag and check the drop
		 * @param	e
		 */
		override protected function onIObjectUp(e:MouseEvent):void
		{
			e.target.stopDrag();
			e.target.removeEventListener(Event.ENTER_FRAME, onIObjectEnterFrame);
			
			_IsDragging = false;
			
			removeDraggingEffect(e.target);
			
			checkChoiceDrop(e.target.choiceIdx);
		}

		/**
		 * Update something as the items is drug around the stage
		 * @param	e
		 */
		protected function onIObjectEnterFrame(e:Event):void
		{
			updateViewAsChoiceIsDragged(e.target);
		}

		/**
		 * Update the view. Override in subclass
		 */
		protected function updateViewAsChoiceIsDragged(choice:Object):void
		{
		}

		// ---------------------------------------------------------------------
		//
		// ACCESSIBILITY
		//
		// ---------------------------------------------------------------------

		/**
		 * Interactive object, focus in handler
		 * @param	e
		 */
		override protected function onIObjectFocusIn(e:FocusEvent):void
		{
			_AccSelectedChoice = e.target.choiceIdx;
			showAccessibilityCues();
		}
		
		/**
		 * Interactive object, focus out handler
		 * @param	e
		 */
		override protected function onIObjectFocusOut(e:FocusEvent):void
		{
			//trace("InteractiveObject Focus Out " + e.target);
			_AccSelectedChoice = -1;
			hideAccessibilityCues();
		}
		
		protected function showAccessibilityCues():void
		{
			_AccessibilityEnabled = true;
			
			for(var i:int=0,len:int=_AccAidSprites.length; i<len; i++)
			{
				TweenMax.to(_AccAidSprites[i],.25,{autoAlpha:1, ease:Quad.easeIn});
			}
		}

		protected function hideAccessibilityCues():void
		{
			_AccessibilityEnabled = false;	
			
			for(var i:int=0,len:int=_AccAidSprites.length; i<len; i++)
			{
				TweenMax.to(_AccAidSprites[i],.25,{autoAlpha:0, ease:Quad.easeIn});
			}		
		}

		
		override protected function respondToKeyPress(keyCode:int, control:Boolean=false, alt:Boolean=false, shift:Boolean = false, location:int=0):void
		{
			if(_AccessibilityEnabled &&
				keyCode > KeyDict.NUM_START &&
				keyCode <= KeyDict.NUM_END)
			{
				var matchSpriteIndex:int = keyCode - KeyDict.NUMBER_OFFSET - 1;
				
				if( matchSpriteIndex < _Model.numItems)
				{
					var matchIndex:int = _MatchSprites[matchSpriteIndex].matchIdx;
					moveChoiceIndexToMatchIndex(_AccSelectedChoice, matchIndex);
				}
			}
		}

		// ---------------------------------------------------------------------
		//
		// DROP/RELEASE
		//
		// ---------------------------------------------------------------------
		
		protected function getMouseLocationPoint():Point
		{
			return new Point(this.stage.mouseX, this.stage.mouseY);
		}
		
		/**
		 * On mouse up, is there a dot on the choice already? Match up the choice to the right spot on the target
		 * @param	c
		 */
		protected function checkChoiceDrop(choiceIndex:int):void
		{
			// if any other dot is on the match send it home
			if(!_Model.getMatchSpriteUnderPoint(getMouseLocationPoint()))
			{
				resetChoiceToHomePosition(choiceIndex, true);
				return;
			}
			moveChoiceIndexToMatchSpriteUnderChoiceSprite(choiceIndex);
		}

		/**
		 * Return the choice home
		 * @param	c choice index
		 * @param ignorematch	return home even if it's on a match
		 */
		protected function resetChoiceToHomePosition(choiceIndex:int, ignorematch:Boolean = false):void
		{
			if(_Model.getChoiceByIdx(choiceIndex).isOnMatch() && !ignorematch) return;
			var choiceItem:Object = _Model.getChoiceByIdx(choiceIndex).choiceSprite as Object;
			setChoiceToMatch(choiceIndex, -1);
			TweenMax.to(choiceItem, 1, {x:choiceItem.origionalXPos, y:choiceItem.origionalYPos, ease:Elastic.easeOut, onUpdate:updateViewAsChoiceIsDragged, onUpdateParams:[choiceItem]});
			onChoiceToHome();
		}

		// ---------------------------------------------------------------------
		//
		// MATCH/TARGET ALIGNMENT
		//
		// ---------------------------------------------------------------------
		
		/**
		 * Align the Object over the match
		 */
		protected function moveChoiceIndexToMatchSpriteUnderChoiceSprite(choice:int):void
		{
			var choiceItem:Object = _Model.getChoiceByIdx(choice).choiceSprite as Object;
			var matchItem:Object = _Model.getMatchSpriteUnderPoint(getMouseLocationPoint()) as Object;

			alignChoiceToMatch(choiceItem, matchItem);
		}

		/**
		 * Move a specific choice to a specific match
		 */
		protected function moveChoiceIndexToMatchIndex(choice:int, match:int):void
		{
			var choiceItem:Object = _Model.getChoiceByIdx(choice).choiceSprite as Object;
			var matchItem:Object = _Model.getMatchSpriteByIndex(match) as Object;

			alignChoiceToMatch(choiceItem, matchItem);
		}

		/**
		 * Align the choice to the match
		 */
		protected function alignChoiceToMatch(choiceItem:Object, matchItem:Object):void
		{
			if(! matchItem) return;

			removeChoicesOnMatch(matchItem, choiceItem.choiceIdx);

			setChoiceToMatch(choiceItem.choiceIdx, matchItem.choiceIdx);

			animateChoiceToMatch(choiceItem, matchItem);
			
			onChoiceToMatch();
		}

		/**
		 * Remove all choices on the match
		 * 
		 */
		protected function removeChoicesOnMatch(matchItem:Object, ignoreChoiceIndex:int = -1):void
		{
			for(var i:int = 0, len:int = _Model.numItems; i < len; i++)
			{
				if(i == ignoreChoiceIndex) continue;
				if(_Model.doesChoiceHitMatch(i, matchItem as Sprite)) resetChoiceToHomePosition(i, true);
			}
		}

		/**
		 * Align the choice to the match and don't remove existing matches
		 * This is used for resuming from a previous attempt
		 * TODO condense with the other functions
		 */
		protected function alignChoiceToMatchNoRemoval(choice:int, match:int):void
		{
			var choiceItem:Object = _Model.getChoiceByIdx(choice).choiceSprite as Object;
			var matchItem:Object = _Model.getMatchSpriteByIndex(match) as Object;

			if(! matchItem) return;

			setChoiceToMatch(choiceItem.choiceIdx, matchItem.choiceIdx);

			animateChoiceToMatch(choiceItem, matchItem);
			
			onChoiceToMatch();
		}

		protected function animateChoiceToMatch(choiceItem:Object, matchItem:Object):void
		{
			var x:int = int((matchItem.width/2)-(choiceItem.width/2)) + matchItem.x;
			var y:int = int((matchItem.height/2)-(choiceItem.height/2)) + matchItem.y;
			TweenMax.to(choiceItem, .25, {x:x, y:y, ease:Quad.easeOut, onUpdate:updateViewAsChoiceIsDragged, onUpdateParams:[choiceItem]});
		}

		// hook for functionality to this event
		protected function onChoiceToMatch():void
		{	
		}

		// hook for functionality to this event
		protected function onChoiceToHome():void
		{	
		}

		// ---------------------------------------------------------------------
		//
		// JUDGING
		//
		// ---------------------------------------------------------------------
		
		/**
		 * Show the correct choices or matches
		 */
		override protected function showCorrectResponses():void
		{
			for(var i:int = 0, len:int = _Model.numItems; i < len; i++)
			{
				if(_Model.getChoiceByIdx(i).isOnMatch())
				{
					showCorrectStatusForChoice(i);
				}
				else
				{
					moveChoiceToCorrectMatch(i);
				}
			}
		}

		protected function showCorrectStatusForChoice(choice:int):void
		{
			//TweenMax.to(Object(_Model.getChoiceByIdx(choide).matchSprite).check_mc, .5, {alpha:1, ease:Quad.easeOut});
		}

		/**
		 * Show the choice on the correct match
		 */
		protected function moveChoiceToCorrectMatch(c:int):void
		{
			// the sorting subtype may line up do a hotpot other than it's "correct" one since it's based on a correct "text"
			// not a match spot. test for that here.
			if(_Model.subType == QuestionModel.SUBTYPE_SORTING)
			{
				if(_Model.getIsChoiceOnAValidSortingMatch(c)) return;
			}
			
			var choiceItem:Object = _Model.getChoiceByIdx(c).choiceSprite as Object;
			var matchItem:Object = _Model.getChoiceByIdx(c).matchSprite as Object;
			
			_Model.getChoiceByIdx(c).onMatchIndex = matchItem.matchIdx;

			var x:int = int((matchItem.width/2)-(choiceItem.width/2)) + matchItem.x;
			var y:int = int((matchItem.height/2)-(choiceItem.height/2)) + matchItem.y;

			TweenMax.killTweensOf(choiceItem);
			TweenMax.to(choiceItem, 3, {x:x, y:y, ease:Back.easeInOut, onUpdate:updateViewAsChoiceIsDragged, onUpdateParams:[choiceItem]});
		}

		/**
		 * Reset the question to it's initial state
		 */
		override protected function resetQuestionView():void
		{
			resetChoiceView();
			resetMatchView();

			super.resetQuestionView();
		}

		protected function resetChoiceView():void
		{
			for(var i:int = 0, len:int = _IObjects.length; i < len; i++)
			{
				resetChoiceToHomePosition(i, true);
			}
		}

		protected function resetMatchView():void
		{
			/*for(var m:int = 0, mlen:int =_Model.numItems; m < mlen; m++)
			{
				_MatchSprites[m].check_mc.alpha = 0;
			}*/
		}

		// ---------------------------------------------------------------------
		//
		// DESTROY
		//
		// ---------------------------------------------------------------------
		
		protected function removeAllIObjectEnterFrameEvents():void
		{
			for(var i:int,len:int=_IObjects.length; i<len; i++)
			{
				_IObjects[i].removeEventListener(Event.ENTER_FRAME, onIObjectEnterFrame);
			}
		}
		
		protected function removeMatchSprites():void
		{
			for(var i:int,len:int=_MatchSprites.length; i<len; i++)
			{
				_IObjectHolder.removeChild(_MatchSprites[i]);
				_MatchSprites[i] = null;
			}
			_MatchSprites = [];
		}
		
		protected function removeStaticMatchSprites():void
		{
			for(var i:int,len:int=_StaticMatchSprites.length; i<len; i++)
			{
				_IObjectHolder.removeChild(_StaticMatchSprites[i]);
				_StaticMatchSprites[i] = null;
			}
			_StaticMatchSprites = [];
		}
		
		protected function removeStaticChoiceSprites():void
		{
			for(var i:int,len:int=_StaticChoiceSprites.length; i<len; i++)
			{
				_IObjectHolder.removeChild(_StaticChoiceSprites[i]);
				_StaticChoiceSprites[i] = null;
			}
			_StaticChoiceSprites = [];
		}
		
		
		protected function removeAccessibilityAids():void
		{
			for(var i:int,len:int=_AccAidSprites.length; i<len; i++)
			{
				_IObjectHolder.removeChild(_AccAidSprites[i]);
				_AccAidSprites[i] = null;
			}
			_AccAidSprites = [];
		}
		
		override public function destroy():void
		{
			removeAllIObjectEnterFrameEvents();
			
			removeMatchSprites();
			removeStaticMatchSprites();
			removeStaticChoiceSprites();
			removeAccessibilityAids();
			
			super.destroy();
		}
	}
}
