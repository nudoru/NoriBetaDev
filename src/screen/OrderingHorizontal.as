package screen
{
	import com.greensock.easing.Quad;

	import flash.display.Sprite;

	import com.greensock.easing.Bounce;
	import com.greensock.TweenMax;

	import flash.text.TextFieldAutoSize;

	import com.nudoru.utilities.ArrayUtilities;

	import assets.view.MatchingText.MatchingDragChoice;

	import com.nudoru.utilities.AccUtilities;
	import com.nudoru.utilities.MathUtilities;

	import screen.controller.IAbstractQuestionScreen;

	/**
	 * @author Matt Perkins
	 */
	public class OrderingHorizontal extends MatchingText implements IAbstractQuestionScreen
	{
		public function OrderingHorizontal()
		{
			super();
		}

		// ---------------------------------------------------------------------
		//
		// RENDER
		//
		// ---------------------------------------------------------------------
		override protected function renderInteraction():void
		{
			configureNColumnLayout(_Model.numItems, 20, 20);

			// Force the matches to be ORDERED
			_RndMatchArray = MathUtilities.createNumArray(_Model.numItems);

			renderChoices();
			renderMatchTargets();
			renderAccessibilityAids();

			// since the choices were created first they're on the bottom of the holder sprite
			// pop them back to the top so they're on top of everything so that
			// accessibility works properly
			raiseChoicesToTopZ();
		}

		override protected function renderChoices():void
		{
			var currentChoiceX:int = _ChoiceColumnX;
			for(var i:int, len:int = _Model.numItems; i < len; i++)
			{
				var choiceItem:MatchingDragChoice = new MatchingDragChoice();
				choiceItem.name = "Choicetile " + _RndChoicesArray[i];
				choiceItem.choiceIdx = _RndChoicesArray[i];
				choiceItem.x = currentChoiceX;
				choiceItem.y = _ChoiceColumnY;
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

				currentChoiceX += _ChoiceAndMatchColumnGutter + (choiceItem.bg_mc.width);
			}

			_TallestItemHeight = getHeightOfTallestMCInArray(_IObjects);
		}

		override protected function renderMatchTargets():void
		{
			var currentMatchX:int = _ChoiceColumnX;
			for(var i:int, len:int = _Model.numItems; i < len; i++)
			{
				var matchTarget:MatchingTargetArea = new MatchingTargetArea();
				matchTarget.name = "Matchitem " + i;
				matchTarget.choiceIdx = _RndMatchArray[i];
				matchTarget.matchIdx = _RndMatchArray[i];
				matchTarget.displayIdx = i;

				matchTarget.x = currentMatchX;
				matchTarget.y = _ChoiceColumnY + _TallestItemHeight + _ChoiceAndMatchColumnGutter;

				matchTarget.hi_mc.alpha = 0;

				matchTarget.bg_mc.scaleX = matchTarget.hi_mc.scaleX = _MatchColumnWidth * .01;
				matchTarget.bg_mc.scaleY = matchTarget.hi_mc.scaleY = _TallestItemHeight * .01;

				matchTarget.number_txt.text = String(i + 1);
				matchTarget.number_txt.x = int((matchTarget.bg_mc.width / 2) - (matchTarget.number_txt.width / 2));
				matchTarget.number_txt.y = int((matchTarget.bg_mc.height / 2) - (matchTarget.number_txt.height / 2));

				matchTarget.check_mc.alpha = 0;
				matchTarget.check_mc.vsibility = false;
				matchTarget.check_mc.x = int((matchTarget.hi_mc.scaleX * 50) - (matchTarget.check_mc.width / 2));

				_IObjectHolder.addChild(matchTarget);
				_MatchSprites.push(matchTarget);

				_Model.getChoiceByIdx(_RndMatchArray[i]).matchSprite = matchTarget;

				currentMatchX += _ChoiceAndMatchColumnGutter + (matchTarget.bg_mc.width);
			}
		}

		override protected function renderAccessibilityAids():void
		{
			for(var i:int, len:int = _MatchSprites.length; i < len; i++)
			{
				var numberIcon:NumberIcon = new NumberIcon();
				numberIcon.number_txt.text = String(i + 1);
				numberIcon.x = int((_MatchSprites[i].width / 2) - (numberIcon.width / 2)) + _MatchSprites[i].x;
				numberIcon.y = _MatchSprites[i].y + _MatchSprites[i].height + 5;

				numberIcon.visible = false;
				numberIcon.alpha = 0;

				_IObjectHolder.addChild(numberIcon);
				_AccAidSprites.push(numberIcon);
			}
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
				_MatchSprites[m].check_mc.y = 0;
				_MatchSprites[m].check_mc.alpha = 0;
			}
		}

		override protected function showCorrectStatusForChoice(choice:int):void
		{
			var check:Sprite = MatchingTargetArea(_Model.getChoiceByIdx(choice).matchSprite).check_mc;
			check.y -= 15;
			TweenMax.to(check, .5, {alpha:1, ease:Quad.easeOut});
		}
	}
}
