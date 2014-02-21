package screen
{
	import flash.display.BlendMode;

	import screen.model.IQuestionChoiceModel;

	import com.nudoru.utilities.MathUtilities;

	import screen.controller.IAbstractQuestionScreen;

	/**
	 * @author Matt Perkins
	 */
	public class MatchingHotspot extends MatchingText implements IAbstractQuestionScreen
	{
		public function MatchingHotspot()
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
			// the sprite in which the interaction objects are rendered is placed at the bottom of the text
			// since the image is positioned on the screen top, need to bump the hotspots so that they are
			// also aligned with the screen top
			_ChoiceAndMatchYOffset = _IObjectHolder.y;

			// create a narrow column width to maximize available area for hotspots
			configureNColumnLayout(4, 60, 60, 60);

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
			for(var i:int, len:int = _Model.numItems; i < len; i++)
			{
				var currentChoice:IQuestionChoiceModel = _Model.getChoiceByIdx(_RndMatchArray[i]);

				var matchTarget:MatchingTargetAreaOutlined = new MatchingTargetAreaOutlined();
				matchTarget.name = "Matchitem " + i;
				matchTarget.choiceIdx = _RndMatchArray[i];
				matchTarget.matchIdx = _RndMatchArray[i];
				matchTarget.displayIdx = i;

				matchTarget.x = currentChoice.hotspotMetrics.x;
				matchTarget.y = currentChoice.hotspotMetrics.y - _ChoiceAndMatchYOffset;

				matchTarget.bg_mc.alpha = 1;
				matchTarget.bg_mc.blendMode = BlendMode.MULTIPLY;
				matchTarget.hi_mc.alpha = 0;

				var hotSpotWidth:int = currentChoice.hotspotMetrics.width;
				var hotSpotHeight:int = currentChoice.hotspotMetrics.height;

				if(hotSpotWidth < _ChoiceColumnWidth) hotSpotWidth = _ChoiceColumnWidth;
				if(hotSpotHeight < _TallestItemHeight) hotSpotHeight = _TallestItemHeight;

				matchTarget.bg_mc.scaleX = matchTarget.hi_mc.scaleX = hotSpotWidth * .01;
				matchTarget.bg_mc.scaleY = matchTarget.hi_mc.scaleY = hotSpotHeight * .01;

				matchTarget.check_mc.alpha = 0;
				matchTarget.check_mc.vsibility = false;
				matchTarget.check_mc.y = int((matchTarget.hi_mc.scaleY * 50) - (matchTarget.check_mc.height / 2));

				_IObjectHolder.addChild(matchTarget);
				_MatchSprites.push(matchTarget);

				_Model.getChoiceByIdx(_RndMatchArray[i]).matchSprite = matchTarget;
			}
		}

		override protected function renderAccessibilityAids():void
		{
			for(var i:int, len:int = _MatchSprites.length; i < len; i++)
			{
				var numberIcon:NumberIcon = new NumberIcon();
				numberIcon.number_txt.text = String(i + 1);
				numberIcon.x = _MatchSprites[i].x + _MatchSprites[i].width + 10;
				numberIcon.y = int((_MatchSprites[i].height / 2) - (numberIcon.height / 2)) + _MatchSprites[i].y;

				numberIcon.visible = false;
				numberIcon.alpha = 0;

				_IObjectHolder.addChild(numberIcon);
				_AccAidSprites.push(numberIcon);
			}
		}
	}
}
