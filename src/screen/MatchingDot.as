package screen
{
	import flash.events.MouseEvent;

	import com.nudoru.utilities.AccUtilities;

	import assets.view.MatchingDot.Dot;

	import screen.controller.AbstractDNDQuestionScreen;
	import screen.controller.IAbstractQuestionScreen;

	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.nudoru.utilities.ArrayUtilities;

	import flash.display.*;
	import flash.text.*;

	/**
	 * Drag and drop matching using dots
	 * 
	 * This one deviates form the template of a DND in a few ways due to the offseting of the dots with the "base" or hole
	 * in the match area
	 * 
	 * @author Matt Perkins
	 */
	public class MatchingDot extends AbstractDNDQuestionScreen implements IAbstractQuestionScreen
	{
		// ---------------------------------------------------------------------
		//
		// VARIABLES
		//
		// ---------------------------------------------------------------------
		protected var _LineSprites:Array = [];
		protected var _LineColors:Array = ["0xD42027", "0x2B59A8", "0x636467", "0x2D8C43", "0xF2C019", "0x7B8BA0", "0xE46425", "0xD42027", "0x2B59A8", "0x636467", "0x2D8C43", "0xF2C019", "0x7B8BA0", "0xE46425"];

		// ---------------------------------------------------------------------
		//
		// CONSTRUCTION
		//
		// ---------------------------------------------------------------------
		/**
		 * Constructor
		 */
		public function MatchingDot()
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

			_ChoiceColumnX = 10;
			_ChoiceColumnY = 0;
			_ChoiceColumnWidth = 340;
			_ChoiceColumnYSpacing = 5;
			_MatchColumnX = screenWidth - 425 - 50;
			_MatchColumnY = 0;
			_MatchColumnWidth = 425;
			_MatchColumnYSpacing = 5;

			renderMatches();
			renderAccessibilityAids();
			renderChoices();
			renderLineLayers();
			renderDots();
		}

		private function renderAccessibilityAids():void
		{
			for(var i:int = 0, len:int = _MatchSprites.length; i < len; i++)
			{
				var numberIcon:NumberIcon = new NumberIcon();
				numberIcon.number_txt.text = String(i + 1);
				numberIcon.x = _MatchSprites[i].x + _MatchSprites[i].width - 30;
				numberIcon.y = int((_MatchSprites[i].height / 2) - (numberIcon.height / 2)) + _MatchSprites[i].y;

				numberIcon.visible = false;
				numberIcon.alpha = 0;

				_IObjectHolder.addChild(numberIcon);
				_AccAidSprites.push(numberIcon);
			}
		}

		private function renderMatches():void
		{
			var currentMatchY:int = _MatchColumnY;
			for(var i:int = 0, len:int = _Model.numItems; i < len; i++)
			{
				var matchItem:MatchingDotMatchItem = new MatchingDotMatchItem();
				matchItem.name = "Matchitem " + i;
				matchItem.choiceIdx = _RndMatchArray[i];
				matchItem.matchIdx = _RndMatchArray[i];
				matchItem.displayIdx = i;

				matchItem.x = _MatchColumnX;
				matchItem.y = currentMatchY;

				matchItem.check_mc.alpha = 0;
				matchItem.text_txt.autoSize = TextFieldAutoSize.LEFT;
				matchItem.text_txt.wordWrap = true;
				matchItem.text_txt.text = _Model.getChoiceByIdx(_RndMatchArray[i]).match;
				matchItem.bg_mc.scaleY = int(10 + matchItem.text_txt.height) * .01;
				matchItem.baseleft_mc.y = int((10 + matchItem.text_txt.height) / 2);
				matchItem.check_mc.y = int((10 + matchItem.text_txt.height) / 2) - 6;

				_IObjectHolder.addChild(matchItem);
				_Model.getChoiceByIdx(_RndMatchArray[i]).matchSprite = matchItem;

				_MatchSprites.push(matchItem);

				currentMatchY += _MatchColumnYSpacing + (matchItem.bg_mc.scaleY * 100);
			}
		}

		private function renderChoices():void
		{
			var currentChoiceY:int = _ChoiceColumnY;
			for(var i:int = 0, len:int = _Model.numItems; i < len; i++)
			{
				var choiceItem:MatchingDotChoiceBG = new MatchingDotChoiceBG();
				choiceItem.name = "Choicetile " + _RndChoicesArray[i];
				choiceItem.x = _ChoiceColumnX;
				choiceItem.y = currentChoiceY;
				choiceItem.matchIdx = ArrayUtilities.getArrayIndexOfValue(_RndChoicesArray[i], _RndMatchArray);

				choiceItem.bg_mc.alpha = .3;
				choiceItem.text_txt.autoSize = TextFieldAutoSize.LEFT;
				choiceItem.text_txt.wordWrap = true;
				choiceItem.text_txt.text = _Model.getChoiceByIdx(_RndChoicesArray[i]).text;
				choiceItem.bg_mc.scaleY = int(10 + choiceItem.text_txt.height) * .01;

				choiceItem.baseright_mc.y = int((10 + choiceItem.text_txt.height) / 2);
				_StaticChoiceSprites.push(choiceItem);

				_IObjectHolder.addChild(choiceItem);

				currentChoiceY += _ChoiceColumnYSpacing + (choiceItem.bg_mc.scaleY * 100);
			}
		}

		private function renderLineLayers():void
		{
			for(var i:int = 0, len:int = _Model.numItems; i < len; i++)
			{
				var lineLayer:Sprite = new Sprite();
				lineLayer.name = "Linelayer " + i;
				_LineSprites.push(lineLayer);
				_IObjectHolder.addChild(lineLayer);
			}
		}

		private function renderDots():void
		{
			for(var i:int = 0, len:int = _Model.numItems; i < len; i++)
			{
				var dotItem:Dot = new Dot();
				dotItem.name = "Dot " + _RndChoicesArray[i];

				dotItem.choiceIdx = _RndChoicesArray[i];
				dotItem.displayIdx = i;
				dotItem.x = _StaticChoiceSprites[i].x + _StaticChoiceSprites[i].baseright_mc.x;
				dotItem.y = _StaticChoiceSprites[i].y + _StaticChoiceSprites[i].baseright_mc.y;

				// set the "home" properties of the dots so they can "snap" back
				dotItem.setOrigionalProps();

				_Model.getChoiceByIdx(_RndChoicesArray[i]).choiceSprite = dotItem;
				_Model.getChoiceByIdx(_RndChoicesArray[i]).onMatchIndex = -1;

				AccUtilities.setTextProperties(dotItem, "Choice " + _Model.getChoiceByIdx(_RndChoicesArray[i]).text);
				dotItem.tabIndex = AccUtilities.tabCounter++;

				_IObjectHolder.addChild(dotItem);
				_IObjects.push(dotItem);

				dotItem.alpha = 0;
				dotItem.scaleX = dotItem.scaleY = 3;
				var ty:int = dotItem.y;
				dotItem.y -= 50;
				TweenMax.to(dotItem, 2, {y:ty, alpha:1, scaleX:1, scaleY:1, ease:Bounce.easeOut, delay:i * .1, onComplete:enableIObject, onCompleteParams:[dotItem]});
			}
		}

		// ---------------------------------------------------------------------
		//
		// INTERACTION
		//
		// ---------------------------------------------------------------------
		override protected function onIObjectOver(e:MouseEvent):void
		{
			e.target.gotoAndStop("over");
		}

		/**
		 * Choice out
		 * @param	e
		 */
		override protected function onIObjectOut(e:MouseEvent):void
		{
			e.target.gotoAndStop("up");
		}

		override protected function updateViewAsChoiceIsDragged(choice:Object):void
		{
			drawLineToDot(choice as Dot);
		}

		/**
		 * Draws a line from the dot's home position to the dot
		 * @param	d
		 */
		protected function drawLineToDot(dot:Dot):void
		{
			var ll:Sprite = _LineSprites[dot.choiceIdx];
			ll.graphics.clear();
			ll.graphics.lineStyle(2, _LineColors[dot.choiceIdx], 1, true);
			ll.graphics.moveTo(dot.origionalXPos, dot.origionalYPos);
			ll.graphics.lineTo(dot.x, dot.y);
		}

		/**
		 * Clears the line
		 * @param	d
		 */
		protected function clearLineToDot(dot:Dot):void
		{
			var ll:Sprite = _LineSprites[dot.choiceIdx];
			ll.graphics.clear();
		}

		/**
		 * Customizing since the match target is a little unique with the addition of the baseleft_mc
		 */
		override protected function animateChoiceToMatch(choiceItem:Object, matchItem:Object):void
		{
			var x:int = matchItem.x + matchItem.baseleft_mc.x;
			var y:int = matchItem.y + matchItem.baseleft_mc.y;
			TweenMax.to(choiceItem, .25, {x:x, y:y, ease:Quad.easeOut, onUpdate:updateViewAsChoiceIsDragged, onUpdateParams:[choiceItem]});
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
				_MatchSprites[m].check_mc.alpha = 0;
			}
		}

		override protected function showCorrectStatusForChoice(choice:int):void
		{
			TweenMax.to(MatchingDotMatchItem(_Model.getChoiceByIdx(choice).matchSprite).check_mc, .5, {alpha:1, ease:Quad.easeOut});
		}

		/**
		 * Custom because of the baseleft_mc
		 */
		override protected function moveChoiceToCorrectMatch(c:int):void
		{
			var choiceItem:Object = _Model.getChoiceByIdx(c).choiceSprite as Object;
			var matchItem:Object = _Model.getChoiceByIdx(c).matchSprite as Object;

			_Model.getChoiceByIdx(c).onMatchIndex = matchItem.matchIdx;

			var x:int = matchItem.x + matchItem.baseleft_mc.x;
			var y:int = matchItem.y + matchItem.baseleft_mc.y;

			TweenMax.killTweensOf(choiceItem);
			TweenMax.to(choiceItem, 3, {x:x, y:y, ease:Back.easeInOut, onUpdate:updateViewAsChoiceIsDragged, onUpdateParams:[choiceItem]});
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