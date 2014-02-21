package screen
{
	import com.nudoru.utilities.MathUtilities;

	import screen.controller.IAbstractQuestionScreen;

	/**
	 * @author Matt Perkins
	 */
	public class OrderingVertical extends MatchingText implements IAbstractQuestionScreen
	{
		public function OrderingVertical()
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
			configureNColumnLayout(2, 60, 60, 60);

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

		override protected function renderMatchTargets():void
		{
			var currentMatchY:int = _MatchColumnY;
			for(var i:int, len:int = _Model.numItems; i < len; i++)
			{
				var matchTarget:MatchingTargetArea = new MatchingTargetArea();
				matchTarget.name = "Matchitem " + i;
				matchTarget.choiceIdx = _RndMatchArray[i];
				matchTarget.matchIdx = _RndMatchArray[i];
				matchTarget.displayIdx = i;

				matchTarget.x = _MatchColumnX;
				matchTarget.y = currentMatchY;

				matchTarget.hi_mc.alpha = 0;

				matchTarget.bg_mc.scaleX = matchTarget.hi_mc.scaleX = _MatchColumnWidth * .01;
				matchTarget.bg_mc.scaleY = matchTarget.hi_mc.scaleY = _TallestItemHeight * .01;

				matchTarget.number_txt.text = String(i + 1);
				matchTarget.number_txt.x = int((matchTarget.bg_mc.width / 2) - (matchTarget.number_txt.width / 2));
				matchTarget.number_txt.y = int((matchTarget.bg_mc.height / 2) - (matchTarget.number_txt.height / 2));

				matchTarget.check_mc.alpha = 0;
				matchTarget.check_mc.vsibility = false;
				matchTarget.check_mc.y = int((matchTarget.hi_mc.scaleY * 50) - (matchTarget.check_mc.height / 2));

				_IObjectHolder.addChild(matchTarget);
				_MatchSprites.push(matchTarget);

				_Model.getChoiceByIdx(_RndMatchArray[i]).matchSprite = matchTarget;

				currentMatchY += _MatchColumnYSpacing + (matchTarget.bg_mc.scaleY * 100);
			}
		}

		override protected function renderAccessibilityAids():void
		{
			for(var i:int, len:int = _MatchSprites.length; i < len; i++)
			{
				var numberIcon:NumberIcon = new NumberIcon();
				numberIcon.number_txt.text = String(i + 1);
				numberIcon.x = _MatchColumnX + _MatchColumnWidth + 10;
				// _MatchSprites[i].x + _MatchSprites[i].width + 10;
				numberIcon.y = int((_MatchSprites[i].height / 2) - (numberIcon.height / 2)) + _MatchSprites[i].y;

				numberIcon.visible = false;
				numberIcon.alpha = 0;

				_IObjectHolder.addChild(numberIcon);
				_AccAidSprites.push(numberIcon);
			}
		}
	}
}
