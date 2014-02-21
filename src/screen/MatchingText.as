package screen
{
	import flash.display.Sprite;

	import assets.view.MatchingText.MatchingDragChoice;

	import com.nudoru.utilities.AccUtilities;

	import screen.controller.AbstractDNDQuestionScreen;
	import screen.controller.IAbstractQuestionScreen;

	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.nudoru.utilities.ArrayUtilities;

	import flash.text.*;

	/**
	 * Drag and drop matching using dots
	 * @author Matt Perkins
	 */
	public class MatchingText extends AbstractDNDQuestionScreen implements IAbstractQuestionScreen
	{
		// ---------------------------------------------------------------------
		//
		// VARIABLES
		//
		// ---------------------------------------------------------------------
		// ---------------------------------------------------------------------
		//
		// CONSTRUCTION
		//
		// ---------------------------------------------------------------------

		public function MatchingText()
		{
			super();
		}

		// ---------------------------------------------------------------------
		//
		// RENDER
		//
		// ---------------------------------------------------------------------
		/**
		 * Draws the interaction
		 */
		override protected function renderInteractiveObjects():void
		{
			super.renderInteractiveObjects();

			renderInteraction();
		}

		protected function renderInteraction():void
		{
			configureNColumnLayout(3, 60, 60, 20);

			renderChoices();
			renderMatches();
			renderMatchTargets();
			renderAccessibilityAids();

			// since the choices were created first they're on the bottom of the holder sprite
			// pop them back to the top so they're on top of everything so that
			// accessibility works properly
			raiseChoicesToTopZ();
		}

		protected function raiseChoicesToTopZ():void
		{
			for(var i:int, len:int = _Model.numItems; i < len; i++)
			{
				_IObjectHolder.addChild(_IObjects[i]);
			}
		}

		protected function renderChoices():void
		{
			var currentChoiceY:int = _ChoiceColumnY;
			for(var i:int, len:int = _Model.numItems; i < len; i++)
			{
				var choiceItem:MatchingDragChoice = new MatchingDragChoice();
				choiceItem.name = "Choicetile " + _RndChoicesArray[i];
				choiceItem.choiceIdx = _RndChoicesArray[i];
				choiceItem.x = _ChoiceColumnX;
				choiceItem.y = currentChoiceY;
				choiceItem.matchIdx = ArrayUtilities.getArrayIndexOfValue(_RndChoicesArray[i], _RndMatchArray);

				choiceItem.hi_mc.alpha = 0;
				choiceItem.text_txt.x = choiceItem.text_txt.y = _ChoiceAndMatchBorder;
				choiceItem.text_txt.width = _ChoiceColumnWidth - (_ChoiceAndMatchBorder * 2);
				choiceItem.text_txt.autoSize = TextFieldAutoSize.CENTER;
				choiceItem.text_txt.wordWrap = true;
				choiceItem.text_txt.text = _Model.getChoiceByIdx(_RndChoicesArray[i]).text;
				choiceItem.bg_mc.scaleX = _ChoiceColumnWidth * .01;
				choiceItem.bg_mc.scaleY = int((_ChoiceAndMatchBorder * 2) + choiceItem.text_txt.height) * .01;

				choiceItem.hi_mc.scaleX = choiceItem.bg_mc.scaleX;
				choiceItem.hi_mc.scaleY = choiceItem.bg_mc.scaleY;

				AccUtilities.setProperties(choiceItem, "Choice " + _Model.getChoiceByIdx(_RndChoicesArray[i]).text);

				_IObjectHolder.addChild(choiceItem);
				_IObjects.push(choiceItem);
				_Model.setChoiceSprite(_RndChoicesArray[i], choiceItem);

				choiceItem.setOrigionalProps();
				var ty:int = choiceItem.y;
				choiceItem.alpha = 0;
				choiceItem.y -= 50;
				TweenMax.to(choiceItem, 2, {y:ty, alpha:1, scaleX:1, scaleY:1, ease:Bounce.easeOut, delay:i * .1, onComplete:enableIObject, onCompleteParams:[choiceItem]});

				_IObjectHolder.addChild(choiceItem);

				currentChoiceY += _ChoiceColumnYSpacing + (choiceItem.bg_mc.scaleY * 100);
			}

			_TallestItemHeight = getHeightOfTallestMCInArray(_IObjects);
		}

		protected function renderMatches():void
		{
			var currentMatchY:int = _MatchColumnY;
			for(var i:int, len:int = _Model.numItems; i < len; i++)
			{
				var matchItem:MatchingMatch = new MatchingMatch();

				matchItem.x = _MatchColumnX;
				matchItem.y = currentMatchY;

				matchItem.text_txt.x = _ChoiceAndMatchBorder;
				matchItem.text_txt.width = _ChoiceColumnWidth - (_ChoiceAndMatchBorder * 2);
				matchItem.text_txt.autoSize = TextFieldAutoSize.LEFT;
				matchItem.text_txt.wordWrap = true;
				matchItem.text_txt.text = _Model.getChoiceByIdx(_RndMatchArray[i]).match;
				matchItem.bg_mc.scaleX = _MatchColumnWidth * .01;

				var matchHeight:int = int((_ChoiceAndMatchBorder * 2) + matchItem.text_txt.height);
				if(matchHeight < _TallestItemHeight) matchHeight = _TallestItemHeight;

				matchItem.bg_mc.scaleY = matchHeight * .01;

				matchItem.text_txt.y = int((matchHeight / 2) - (matchItem.text_txt.height / 2));

				_IObjectHolder.addChild(matchItem);
				_StaticMatchSprites.push(matchItem);

				currentMatchY += _MatchColumnYSpacing + (matchItem.bg_mc.scaleY * 100);
			}
		}

		protected function renderMatchTargets():void
		{
			var currentMatchY:int = _MatchColumnY;
			for(var i:int, len:int = _Model.numItems; i < len; i++)
			{
				var matchTarget:MatchingTargetArea = new MatchingTargetArea();
				matchTarget.name = "Matchitem " + i;
				matchTarget.choiceIdx = _RndMatchArray[i];
				matchTarget.matchIdx = _RndMatchArray[i];
				matchTarget.displayIdx = i;

				matchTarget.x = _MatchColumnX - _MatchColumnWidth - _ChoiceAndMatchColumnGutter;
				matchTarget.y = currentMatchY;

				matchTarget.bg_mc.alpha = .5;
				matchTarget.hi_mc.alpha = 0;

				matchTarget.bg_mc.scaleX = matchTarget.hi_mc.scaleX = _MatchColumnWidth * .01;
				matchTarget.bg_mc.scaleY = matchTarget.hi_mc.scaleY = _TallestItemHeight * .01;

				matchTarget.check_mc.alpha = 0;
				matchTarget.check_mc.vsibility = false;
				matchTarget.check_mc.y = int((matchTarget.hi_mc.scaleY * 50) - (matchTarget.check_mc.height / 2));

				_IObjectHolder.addChild(matchTarget);
				_MatchSprites.push(matchTarget);

				_Model.getChoiceByIdx(_RndMatchArray[i]).matchSprite = matchTarget;

				currentMatchY += _MatchColumnYSpacing + (matchTarget.bg_mc.scaleY * 100);
			}
		}

		protected function renderAccessibilityAids():void
		{
			for(var i:int, len:int = _MatchSprites.length; i < len; i++)
			{
				var numberIcon:NumberIcon = new NumberIcon();
				numberIcon.number_txt.text = String(i + 1);
				numberIcon.x = _StaticMatchSprites[i].x + _StaticMatchSprites[i].width + 10;
				numberIcon.y = int((_StaticMatchSprites[i].height / 2) - (numberIcon.height / 2)) + _StaticMatchSprites[i].y;

				numberIcon.visible = false;
				numberIcon.alpha = 0;

				_IObjectHolder.addChild(numberIcon);
				_AccAidSprites.push(numberIcon);
			}
		}

		// ---------------------------------------------------------------------
		//
		// INTERACTION
		//
		// ---------------------------------------------------------------------
		override protected function updateViewAsChoiceIsDragged(choice:Object):void
		{
			if(! _IsDragging) return;

			var matchUnder:Object = _Model.getMatchSpriteUnderPoint(getMouseLocationPoint());

			if(matchUnder) TweenMax.to(matchUnder.hi_mc, .25, {alpha:.5, ease:Quad.easeOut});

			fadeTargetHilightsIgnoring(matchUnder);
		}

		protected function fadeTargetHilightsIgnoring(ignoreTarget:Object = undefined):void
		{
			for(var i:int,len:int = _MatchSprites.length;i < len;i++)
			{
				if(_MatchSprites[i] == ignoreTarget) continue;
				TweenMax.to(_MatchSprites[i].hi_mc, .5, {alpha:0, ease:Quad.easeOut});
			}
		}

		override protected function onChoiceToMatch():void
		{
			fadeTargetHilightsIgnoring();
		}

		override protected function onChoiceToHome():void
		{
			fadeTargetHilightsIgnoring();
		}

		// ---------------------------------------------------------------------
		//
		// JUDGING
		//
		// ---------------------------------------------------------------------
		override protected function resetMatchView():void
		{
			for(var m:int = 0, mlen:int = _Model.numItems; m < mlen; m++)
			{
				_MatchSprites[m].check_mc.x = 0;
				_MatchSprites[m].check_mc.alpha = 0;
			}
		}

		override protected function showCorrectStatusForChoice(choice:int):void
		{
			var check:Sprite = Object(_Model.getChoiceByIdx(choice).matchSprite).check_mc;
			check.x -= 15;
			TweenMax.to(check, .5, {alpha:1, ease:Quad.easeOut});
		}

		// ---------------------------------------------------------------------
		//
		// DESTROY
		//
		// ---------------------------------------------------------------------
		
		
		/**
		 * Remove listeners and display objects
		 */
		override public function destroy():void
		{
			super.destroy();
		}
	}
}