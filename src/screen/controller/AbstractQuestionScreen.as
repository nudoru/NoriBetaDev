package screen.controller
{
	import com.nudoru.utilities.AccUtilities;
	import com.nudoru.lms.scorm.InteractionObject;
	import com.nudoru.lms.scorm.InteractionType;
	import screen.model.QuestionChoiceModel;
	import screen.model.QuestionModel;
	import com.greensock.easing.Quad;
	import com.nudoru.constants.ObjectStatus;
	import com.nudoru.components.ComponentEvent;
	import com.greensock.TweenMax;
	import com.nudoru.components.Button;

	/**
	 * Provide common functionality for all question screens
	 * @author Matt Perkins
	 */
	public class AbstractQuestionScreen extends AbstractInteractiveScreen implements IAbstractQuestionScreen
	{
		
		//---------------------------------------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------------------------------------
		
		protected var _Model				:QuestionModel;
		
		protected var _SubmitButton			:Button;
		protected var _RetryButton			:Button;
		
		// the choices may be randomized - use this instead of the linear counter
		protected var _RndChoicesArray:Array = [];
		
		public function AbstractQuestionScreen()
		{
			super();
		}
		
		//---------------------------------------------------------------------
		//
		//	INITIALIZATION
		//
		//---------------------------------------------------------------------

		/**
		 * Create model from loaded XML
		 * @param	data
		 */
		override protected function parseLoadedXML(data:XML):void
		{
			_Model = new QuestionModel(data);
		}
		
		//---------------------------------------------------------------------
		//
		//	RENDER
		//
		//---------------------------------------------------------------------
		
		/**
		 * Draws the view
		 */
		override protected function renderScreen():void
		{
			// render title, text and CTA
			renderCommonScreenElements(_Model);
			// renders the question
			renderInteractiveObjects();
			// create standard input buttons
			createSubmitRetryButtons();

			//trace("Last completion status: "+_PreviousCompletionStatus);
			//trace("Last inter object: "+_PreviousInteractionObject);
			
			if(_PreviousInteractionObject || _PreviousCompletionStatus == ObjectStatus.PASSED)
			{
				stopAllIObjectAnimations();
				
				if(_PreviousInteractionObject)
				{
					 restoreQuestionState(_PreviousInteractionObject.learnerResponse);
				}
				else
				{
					 if(_PreviousCompletionStatus == ObjectStatus.PASSED) restoreQuestionState(_Model.getCorrectResponsePattern()[0]);
				}
			}

			
			// TODO test for reenable!
			//ENABLE if hasPageBeenPreviouslyCompleted() && isPageScored && Settings.getInstance().allowScoredReanswer
			//DISABLE if hasPageBeenPreviouslyCompleted() && isPageScored && !Settings.getInstance().allowScoredReanswer
			//If previously correct, show the correct state
		 	//If previously incorrect, show from interaction object
		 	//If incorrect and no interaction obect the allow reanswer
		 	
			_Model.startTimer();
		}

		/**
		 * Revert to an answered state from the response string.
		 * Format is Learner Repsonse SCORM 2004 pattern
		 */
		protected function restoreQuestionState(responseState:String):void
		{
		}
		
		//---------------------------------------------------------------------
		//
		//	COMMON BUTTONS
		//
		//---------------------------------------------------------------------
		
		/**
		 * Draws the Submit and Retry buttons
		 */
		protected function createSubmitRetryButtons():void
		{
			var buttonX:int = int((this.stage.stageWidth/2)-(50)); 
			var buttonY:int = _IObjectHolder.y + _IObjectHolder.height + 10;
			
			// keep the buttons from going off of the button of the screen view.
			// TODO - don't hardcode "-40"
			if(buttonY > (screenHeight - 40)) buttonY = screenHeight-40;
			
			_SubmitButton = createCommonButton("Submit");
			_SubmitButton.x = buttonX;
			_SubmitButton.y = buttonY;
			_InteractionLayer.addChild(_SubmitButton);
			_SubmitButton.addEventListener(ComponentEvent.EVENT_CLICK, onSubmitClick, false, 0, true);
			TweenMax.to(_SubmitButton, 0, { alpha:0, blurFilter: { blurX:20, blurY:20 }} );	
			disableButton(_SubmitButton);
			
			_RetryButton = createCommonButton("Retry");
			_RetryButton.x = _SubmitButton.x + 125;
			_RetryButton.y = _SubmitButton.y;
			_InteractionLayer.addChild(_RetryButton);
			_RetryButton.addEventListener(ComponentEvent.EVENT_CLICK, onRetryClick, false, 0, true);
			TweenMax.to(_RetryButton, 0, { alpha:0, blurFilter: { blurX:20, blurY:20 }} );
			disableButton(_RetryButton);
			
			setTabIndexOnSubmitRetryButtons();
		}

		protected function setTabIndexOnSubmitRetryButtons():void
		{
			_SubmitButton.tabIndex = AccUtilities.tabCounter++;
			_RetryButton.tabIndex = AccUtilities.tabCounter++;
		}

		/**
		 * Submit button click
		 * @param	e
		 */
		protected function onSubmitClick(e:ComponentEvent):void
		{
			if(isButtonEnabled(_SubmitButton)) processLearnerResponse();
		}
		
		/**
		 * Submit button click
		 * @param	e
		 */
		protected function onRetryClick(e:ComponentEvent):void
		{
			if(isButtonEnabled(_RetryButton)) resetQuestionView();
		}
		
		/**
		 * Is a NudoruButton (submit/reset) enabled?
		 */
		protected function isButtonEnabled(button:Button):Boolean
		{
			return button.alpha == 1;
		}
		
		/**
		 * Show a disabled state for a NudoruButton
		 */
		protected function disableButton(button:Button):void
		{
			button.enabled = false;
			TweenMax.to(button, .25, { alpha:.25, ease:Quad.easeOut, blurFilter: { blurX:2, blurY:2}} );
		}
		
		/**
		 * Show an enabled state for a NudoruButton
		 */
		protected function enableButton(button:Button):void
		{
			button.enabled = true;
			TweenMax.to(button, .25, { alpha:1, ease:Quad.easeOut, blurFilter: { blurX:0, blurY:0}} );
		}
		
		//---------------------------------------------------------------------
		//
		//	JUDGING
		//
		//---------------------------------------------------------------------
		
		/**
		 * Sets a choice selected
		 */
		protected function selectChoice(choice:int):void
		{
			var choiceModel:QuestionChoiceModel = _Model.getChoiceByIdx(choice);
			// deselect it if it's selected, select it if it's not
			if(_Model.getChoiceSelected(choice))
			{
				_Model.setChoiceSelected(choice, false);
			} 
			else 
			{
				if (_Model.singleSelect)
				{
					_Model.deselectAllChoices();
					resetChoiceViews(choiceModel.id);
				}
				_Model.setChoiceSelected(choice, true);
			}
			
			evaluateButtonStates();
		}
		
		/**
		 * Assign a choice to a match
		 */
		protected function setChoiceToMatch(choice:int, match:int):void
		{
			_Model.setChoiceOnMatch(choice, match);
			
			evaluateButtonStates();
		}
		
		/**
		 * Determines if the submit/etc. buttons should be enabled/disabled for each question type
		 */
		protected function evaluateButtonStates():void
		{
			var enable:Boolean = false;

			if(_Model.type == InteractionType.CHOICE) enable = _Model.isAnyChoiceSelected();
				else if(_Model.type == InteractionType.MATCHING) enable = _Model.areAllChoicesMatched();
			
			if(enable)
			{
				enableButton(_SubmitButton);
				enableButton(_RetryButton);
			}
			else 
			{
				disableButton(_SubmitButton);
				disableButton(_RetryButton);
			}
		}
		
		/**
		 * Remove the selected state from all choices
		 */
		protected function resetChoiceViews(ignoreid:String):void
		{	
			//
		}
		
		/**
		 * Process what the learner did to answer the question
		 */
		protected function processLearnerResponse():void
		{
			_IObjectHolder.mouseChildren = false;

			var correct:Boolean = judgeLearnerResponse();

			// increment number of tries and see if there are any left OR it's correct and you don't need more
			if(!_Model.nextTry() || correct)
			{
				setScreenStatusTo((correct ? ObjectStatus.PASSED : ObjectStatus.FAILED), _Model.createInteractionObject());
				showCorrectResponses();
			}
			
			showFeedback((correct ? "Correct" : "Incorrect"), _Model.getFeedback());
			
			disableButton(_SubmitButton);
			
			disableInteraction();
		}
		
		/**
		 * Determine if the learner answered the question correctly or not
		 */
		protected function judgeLearnerResponse():Boolean
		{
			return _Model.isCorrect();
		}
		
		/**
		 * Show the correct choices or matches
		 */
		protected function showCorrectResponses():void
		{
		}
		
		/**
		 * Display a message to the learner
		 */
		protected function showFeedback(title:String, message:String):void
		{
			showMessage(title, message);
		}
		
		/**
		 * Perform functions when the window is closed
		 */
		override protected function handleMessageWindowClosed():void
		{
			// error will happen if the framework has navigated away and these object aren't available
			try {
				if(_Model.hasAnotherTry())
				{
					enableInteraction();
					resetQuestionView();
				}
			} catch(e:*){}
		}
		
		/**
		 * Reset the view to the initial unanswered state
		 */
		protected function resetQuestionView():void
		{
			_SWindowManager.removeAllWindows();
			_IObjectHolder.mouseChildren = true;
			_Model.deselectAllChoices();
			
			disableButton(_SubmitButton);
			disableButton(_RetryButton);
		}

		//---------------------------------------------------------------------
		//
		//	DESTROY
		//
		//---------------------------------------------------------------------
		
		/**
		 * Remove listeners and display objects
		 */
		override public function destroy():void
		{
			_SubmitButton.removeEventListener(ComponentEvent.EVENT_CLICK, onSubmitClick);
			_InteractionLayer.addChild(_SubmitButton);
			_SubmitButton = undefined;
			
			_RetryButton.removeEventListener(ComponentEvent.EVENT_CLICK, onRetryClick);
			_InteractionLayer.addChild(_RetryButton);
			_RetryButton = undefined;
			
			_Model.stopTimer();
			_Model.destroy();
			
			_Model = undefined;
			
			super.destroy();
		}

	}
}
