package screen
{
	import assets.view.MatchingText.MatchingDragChoice;

	import com.nudoru.utilities.MathUtilities;

	import flash.display.MovieClip;

	import assets.view.SortingText.SortingColumn;

	import com.nudoru.utilities.AccUtilities;

	import screen.controller.IAbstractQuestionScreen;

	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.nudoru.utilities.ArrayUtilities;

	import flash.text.*;

	/**
	 * Drag and drop matching by sorting in to columns
	 * 
	 * @author Matt Perkins
	 */
	public class SortingText extends MatchingText implements IAbstractQuestionScreen
	{
		// ---------------------------------------------------------------------
		//
		// VARIABLES
		//
		// ---------------------------------------------------------------------
		private var _UniqueMatchNames:Array;
		private var _TallestMatchColumn:int;

		public function get numUniqueMatches():int
		{
			return _UniqueMatchNames.length;
		}

		// ---------------------------------------------------------------------
		//
		// CONSTRUCTION
		//
		// ---------------------------------------------------------------------
		public function SortingText()
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
			// Force the matches to be ORDERED
			_RndMatchArray = MathUtilities.createNumArray(_Model.numItems);

			_UniqueMatchNames = _Model.getAllUniqueMatchNames();

			_ChoiceAndMatchColumnGutter = 60;

			configureNColumnLayout(numUniqueMatches, 60, 160);

			renderChoices();
			// resizeChoicesToTallest();

			renderMatchColumns();
			renderMatchTargets();

			randomlyPositionChoices();

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

				_IObjectHolder.addChild(choiceItem);

				currentChoiceX += _ChoiceAndMatchColumnGutter + (choiceItem.bg_mc.width);
			}

			_TallestItemHeight = getHeightOfTallestMCInArray(_IObjects);
		}

		private function randomlyPositionChoices():void
		{
			var xMin:int = 20;
			var xMax:int = screenWidth - 20 - _ChoiceColumnWidth;

			var yMin:int = _TallestMatchColumn + 30;
			var yMax:int = screenHeight - _IObjectHolder.y - 50 - _TallestItemHeight;

			if(yMax < yMin) 
			{
				yMin = _TallestMatchColumn + 5;
				yMax = yMin + 20;
			}

			for(var i:int, len:int = _IObjects.length; i < len; i++)
			{
				var choiceItem:MovieClip = _IObjects[i] as MovieClip;
				choiceItem.x = MathUtilities.rndNum(xMin, xMax);
				choiceItem.y = MathUtilities.rndNum(yMin, yMax);

				choiceItem.setOrigionalProps();

				var ty:int = choiceItem.y;
				choiceItem.alpha = 0;
				TweenMax.to(choiceItem, 1, {y:ty, alpha:1, scaleX:1, scaleY:1, ease:Quad.easeIn, delay:i * .1, onComplete:enableIObject, onCompleteParams:[choiceItem]});
			}
		}

		protected function renderMatchColumns():void
		{
			var currentMatchX:int = _ChoiceColumnX;
			for(var i:int, len:int = numUniqueMatches; i < len; i++)
			{
				var column:SortingColumn = new SortingColumn();

				column.x = currentMatchX - _ChoiceAndMatchBorder;
				column.y = _MatchColumnY;
				// + 45 to account for the number icon above the column

				column.text_txt.x = column.text_txt.y = _ChoiceAndMatchBorder;
				column.text_txt.width = _ChoiceColumnWidth - (_ChoiceAndMatchBorder * 2);
				column.text_txt.autoSize = TextFieldAutoSize.CENTER;
				column.text_txt.wordWrap = true;

				column.text_txt.text = _UniqueMatchNames[i];
				column.bg_mc.scaleX = column.line_mc.scaleX = (_MatchColumnWidth + _ChoiceAndMatchBorder) * .01;
				column.line_mc.y = column.text_txt.y + column.text_txt.height + _ChoiceAndMatchBorder;

				var matchHeight:int = column.line_mc.y + _MatchColumnYSpacing;
				var matchesForColumn:int = _Model.getNumberOfMatchesWithMatchText(_UniqueMatchNames[i]);
				matchHeight += (matchesForColumn * _TallestItemHeight) + ((matchesForColumn - 1) * _MatchColumnYSpacing) + _ChoiceAndMatchBorder;

				column.bg_mc.scaleY = matchHeight * .01;

				column.numbericon_mc.x = int((_MatchColumnWidth / 2) - (column.numbericon_mc.width / 2));
				column.numbericon_mc.number_txt.text = String(i + 1);
				column.numbericon_mc.visible = false;

				_IObjectHolder.addChild(column);
				_StaticMatchSprites.push(column);

				if(matchHeight > _TallestMatchColumn) _TallestMatchColumn = matchHeight;

				currentMatchX += _ChoiceAndMatchColumnGutter + (column.bg_mc.width);
			}
		}

		private function getMatchColumnForMatchText(text:String):SortingColumn
		{
			for(var i:int, len:int = numUniqueMatches; i < len; i++)
			{
				if(_StaticMatchSprites[i].text_txt.text == text) return _StaticMatchSprites[i] as SortingColumn;
			}
			return undefined;
		}

		override protected function renderMatchTargets():void
		{
			for(var i:int, len:int = _Model.numItems; i < len; i++)
			{
				var currentColumn:SortingColumn = getMatchColumnForMatchText(_Model.getChoiceMatchText(_RndMatchArray[i]));

				var matchTarget:MatchingTargetAreaOutlined = new MatchingTargetAreaOutlined();
				matchTarget.name = "Matchitem " + i;
				matchTarget.choiceIdx = _RndMatchArray[i];
				matchTarget.matchIdx = _RndMatchArray[i];
				matchTarget.displayIdx = i;

				matchTarget.x = currentColumn.x + _ChoiceAndMatchBorder;

				var columnMin:int = currentColumn.y + currentColumn.line_mc.y + _MatchColumnYSpacing;

				matchTarget.y = columnMin + (currentColumn.numTargetsCreatedInColumn * _TallestItemHeight) + ((currentColumn.numTargetsCreatedInColumn) * _MatchColumnYSpacing);

				matchTarget.hi_mc.alpha = 0;

				matchTarget.bg_mc.scaleX = matchTarget.hi_mc.scaleX = _MatchColumnWidth * .01;
				matchTarget.bg_mc.scaleY = matchTarget.hi_mc.scaleY = _TallestItemHeight * .01;

				matchTarget.check_mc.alpha = 0;
				matchTarget.check_mc.vsibility = false;
				matchTarget.check_mc.y = int((matchTarget.hi_mc.scaleY * 50) - (matchTarget.check_mc.height / 2));

				/*matchTarget.number_txt.text = String(i + 1);
				matchTarget.number_txt.x = int((matchTarget.bg_mc.width / 2) - (matchTarget.number_txt.width / 2));
				matchTarget.number_txt.y = int((matchTarget.bg_mc.height / 2) - (matchTarget.number_txt.height / 2));*/

				_IObjectHolder.addChild(matchTarget);
				_MatchSprites.push(matchTarget);

				_Model.getChoiceByIdx(_RndMatchArray[i]).matchSprite = matchTarget;

				// less code to create the number here vs a dedicated function
				var numberIcon:NumberIcon = new NumberIcon();
				numberIcon.number_txt.text = String(i + 1);
				numberIcon.x = matchTarget.x + _MatchColumnWidth + 10;
				numberIcon.y = int((matchTarget.height / 2) - (numberIcon.height / 2)) + matchTarget.y;
				numberIcon.visible = false;
				numberIcon.alpha = 0;

				_IObjectHolder.addChild(numberIcon);
				_AccAidSprites.push(numberIcon);

				currentColumn.numTargetsCreatedInColumn++;
			}
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