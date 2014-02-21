package screen
{
	import com.nudoru.utilities.MathUtilities;
	import com.nudoru.utilities.AccUtilities;
	import com.nudoru.constants.KeyDict;

	import screen.controller.AbstractQuestionScreen;
	import screen.model.*;

	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.plugins.MotionBlurPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.nudoru.components.*;
	import com.nudoru.visual.BMUtils;

	import flash.display.*;

	/**
	 * Multiple choice question interaction
	 * @author Matt Perkins
	 */
	public class MultipleChoice extends AbstractQuestionScreen
	{
		// ---------------------------------------------------------------------
		//
		// VARIABLES
		//
		// ---------------------------------------------------------------------
		protected var _CAChecks:Vector.<CACheck>;

		// ---------------------------------------------------------------------
		//
		// CONSTRUCTION
		//
		// ---------------------------------------------------------------------

		public function MultipleChoice()
		{
			super();
		}

		// ---------------------------------------------------------------------
		//
		// RENDER
		//
		// ---------------------------------------------------------------------
		/**
		 * Draws the main menu items
		 */
		override protected function renderInteractiveObjects():void
		{
			_RndChoicesArray = MathUtilities.createNumArray(_Model.numItems);
			if(_Model.randomizeChoices) _RndChoicesArray = MathUtilities.rndNumArray(_Model.numItems, true);

			TweenPlugin.activate([MotionBlurPlugin]);

			_CAChecks = new Vector.<CACheck>();

			_IObjectHolder = new Sprite();
			_IObjectHolder.x = int((screenWidth / 2) - (350));
			_IObjectHolder.y = _CTATextTB.y + _CTATextTB.measure().height + screenBorder;

			_InteractionLayer.addChild(_IObjectHolder);

			var x:int = 0;
			var y:int = 0;
			var ySpace:int = 2;

			for(var i:int = 0, len:int = _Model.numItems; i < len; i++)
			{
				var cChoice:QuestionChoiceModel = _Model.getChoiceByIdx(_RndChoicesArray[i]);

				// icon for the button, show a check if completed
				var btnIcon:Object;
				if(_Model.singleSelect) btnIcon = {symbol:new RadioButton(), width:12, height:12, halign:"left"};
				else btnIcon = {symbol:new CheckBoxButton(), width:12, height:12, halign:"left"};

				var button:Button = new Button();
				button.initialize({width:700, label:cChoice.text, showface:false, facecolor:0xeeeeee, font:"Verdana", labelalign:"left", size:13, color:0x0052c2, bordersize:1, toggle:true, icon:btnIcon});
				button.data = _Model.getChoiceByIdx(_RndChoicesArray[i]).id;
				button.render();
				button.x = x;
				button.y = y;

				_IObjectHolder.addChild(button);
				_IObjects.push(button);

				_Model.setChoiceSprite(_RndChoicesArray[i], button);

				button.tabIndex = AccUtilities.tabCounter++;

				button.addEventListener(ComponentEvent.EVENT_ACTIVATE, onChoiceButtonOver, false, 0, true);
				button.addEventListener(ComponentEvent.EVENT_DEACTIVATE, onChoiceButtonOut, false, 0, true);
				button.addEventListener(ComponentEvent.EVENT_CLICK, onChoiceButtonClick, false, 0, true);

				button.alpha = 0;
				TweenMax.to(button, 2, {alpha:1, ease:Quad.easeOut, delay:(i * .2) + 1});

				y += button.height + ySpace;
			}
		}

		/**
		 * Revert to an answered state from the response string.
		 * Format is Learner Repsonse SCORM 2004 pattern
		 */
		override protected function restoreQuestionState(responseState:String):void
		{
			var learnerRespones:Array = responseState.split(",");
			for(var i:int = 0,len:int = learnerRespones.length;i < len;i++)
			{
				selectChoice(int(learnerRespones[i]));
			}
		}

		// ---------------------------------------------------------------------
		//
		// INTERACTION
		//
		// ---------------------------------------------------------------------
		/**
		 * Choice button over
		 * @param	e
		 */
		protected function onChoiceButtonOver(e:ComponentEvent):void
		{
			//
		}

		/**
		 * Choice button out
		 * @param	e
		 */
		protected function onChoiceButtonOut(e:ComponentEvent):void
		{
			//
		}

		/**
		 * Choice button click
		 * @param	e
		 */
		protected function onChoiceButtonClick(e:ComponentEvent):void
		{
			selectChoice(_Model.getChoiceIdxByID(e.target.data));
		}

		/**
		 * Remove the selected state from all choices
		 */
		override protected function resetChoiceViews(ignoreid:String):void
		{
			for(var i:int = 0, len:int = numIObjects; i < len; i++)
			{
				if(_IObjects[_RndChoicesArray[i]].data != ignoreid) _IObjects[_RndChoicesArray[i]].selected = false;
			}
		}

		/**
		 * Sets a choice selected. Need to show the selection on the button 
		 */
		override protected function selectChoice(choice:int):void
		{
			// super behavior
			super.selectChoice(choice);

			// trace(choice+", "+_RndChoicesArray[choice]);

			// make sure the button displays the state
			if(_Model.getChoiceSelected(choice)) _Model.getChoiceSprite(choice).showSelected();
			else _Model.getChoiceSprite(choice).showUnselected();
		}

		// ---------------------------------------------------------------------
		//
		// ACCESSIBILITY
		//
		// ---------------------------------------------------------------------
		override protected function respondToKeyPress(keyCode:int, control:Boolean = false, alt:Boolean = false, shift:Boolean = false, location:int = 0):void
		{
			if(	keyCode >= KeyDict.ALPHA_START && keyCode <= KeyDict.ALPHA_END)
			{
				var choiceIndex:int = keyCode - KeyDict.ALPHA_OFFSET;

				if(choiceIndex < _Model.numItems)
				{
					selectChoice(choiceIndex);
				}
			}
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
				if(_Model.getIsChoiceCorrect(i))
				{
					showChoiceAsCorrect(_Model.getChoiceSprite(i));
				}
			}
		}

		// this is not desired since remediation may confuse learners
		protected function showChoiceAsIncorrect(choice:Object):void
		{
			trace("show incorrect: " + choice.data);
		}

		protected function showChoiceAsCorrect(choice:Object):void
		{
			var check:CACheck = new CACheck();
			check.x = choice.x;
			check.y = int((choice.height / 2) - (check.height / 2)) + choice.y;

			_IObjectHolder.addChild(check);
			_CAChecks.push(check);

			check.alpha = 0;
			TweenMax.to(check, .5, {x:choice.x - check.width - 5, alpha:1, ease:Back.easeOut});
		}

		/**
		 * Submit button click
		 * @param	e
		 */
		override protected function resetQuestionView():void
		{
			super.resetQuestionView();

			resetChoiceViews(undefined);
			deleteChecks();
		}

		protected function deleteChecks():void
		{
			for(var i:int = 0, len:int = _CAChecks.length; i < len; i++)
			{
				_IObjectHolder.removeChild(_CAChecks[i]);
			}
			_CAChecks = new Vector.<CACheck>();
		}

		// ---------------------------------------------------------------------
		//
		// DESTROY
		//
		// ---------------------------------------------------------------------
		/**
		 * Remove listeners and display objects
		 */
		// TODO remove choices
		override public function destroy():void
		{
			super.destroy();
		}
	}
}