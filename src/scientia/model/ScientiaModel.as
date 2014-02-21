package scientia.model
{
	import com.nudoru.constants.ObjectStatus;
	import com.nudoru.debug.Debugger;
	import com.nudoru.lms.scorm.InteractionObject;
	import com.nudoru.noriplugins.bindablemodel.model.BindableModel;

	import org.osflash.signals.Signal;

	import scientia.events.signals.ScientiaModelSignals;
	import scientia.model.VOs.ConfigVO;
	import scientia.model.consts.CompletionCriteria;
	import scientia.model.structure.IScreenVO;
	import scientia.model.structure.IStructureVO;

	/**
	 * Model for a screen based app 
	 */
	public class ScientiaModel extends BindableModel implements IScientiaModel
	{
		// ---------------------------------------------------------------------
		//
		// VARIABLES
		//
		// ---------------------------------------------------------------------

		private var _ModelConfigDeserializer:IModelConfigurationDeserializer;
		private var _momentoProcessor:IModelMomentoProcessor;

		// ---------------------------------------------------------------------
		//
		// GETTER/SETTER
		//
		// ---------------------------------------------------------------------
		
		public function get modelConfigDeserializer():IModelConfigurationDeserializer
		{
			return _ModelConfigDeserializer;
		}

		[Inject]
		public function set modelConfigDeserializer(modelConfigVOFactory:IModelConfigurationDeserializer):void
		{
			_ModelConfigDeserializer = modelConfigVOFactory;
			
			// set the UI based on the theme data from the config file
			Settings.setDefaults(configVO.themeVO);
			// set the global prop from the config file
			Settings.audioEnable = configVO.audioEnable;
		}
		
		/**
		 * The configuration value object. This should only be set when Nori is starting up. Data is set by the config.xml file.
		 */
		public function get configVO():ConfigVO
		{
			return _ModelConfigDeserializer.configVO;
		}

		/**
		 * The content value object. This should only be set when Nori is starting up. Data is set by the content.xml file.
		 */
		public function get structureVO():IStructureVO
		{
			return _ModelConfigDeserializer.structureVO;
		}

		/**
		 * ID used to track via cookies/lso
		 */
		public function get LSOID():String
		{
			// converts the name to lower case and replaces spaces with underscores
			var str:String = configVO.name.toLowerCase();
			str = str.replace(/\s+/g, "_");
			return str;
		}

		// ---------------------------------------------------------------------
		//
		// INITIALIZATION
		//
		// ---------------------------------------------------------------------
		/**
		 * Constructor
		 */
		public function ScientiaModel()
		{
			super();
		}

		/**
		 * Initializes the model
		 */
		[PostConstruct]
		override public function initialize():void
		{
			_momentoProcessor = new ModelMomentoProcessor(this);
		}

		// ---------------------------------------------------------------------
		//
		// RESUME DATA
		//
		// ---------------------------------------------------------------------
		public function getSuspendData():String
		{
			return _momentoProcessor.getMomento();
		}

		public function processSuspendData(data:String):Boolean
		{
			return _momentoProcessor.processMomento(data);
		}

		// ---------------------------------------------------------------------
		//
		// STRUCTURE
		//
		// ---------------------------------------------------------------------
		/**
		 * Gets the current screen
		 * @return	Current screen
		 */
		public function getCurrentScreen():IScreenVO
		{
			return structureVO.getCurrentScreen();
		}

		/**
		 * Goes to the first screen in the structure. Called on initial startup
		 * @return
		 */
		public function gotoFirstScreen():IScreenVO
		{
			var screen:IScreenVO = structureVO.firstScreen();
			dispatchScreenChangeSignal();
			return screen;
		}

		/**
		 * Test for linear previous screen
		 * @return
		 */
		public function isLinearPreviousScreen():Boolean
		{
			return structureVO.isLinearPreviousScreen();
		}

		/**
		 * Test for linear previous screen
		 * @return
		 */
		public function isLinearNextScreen():Boolean
		{
			return structureVO.isLinearNextScreen();
		}

		/**
		 * Is there an allowable next screen
		 * @return
		 */
		public function isNextScreen():Boolean
		{
			return isLinearNextScreen();
		}

		/**
		 * Is there an allowable previous screen
		 * @return
		 */
		public function isPreviousScreen():Boolean
		{
			return isLinearPreviousScreen();
		}

		/**
		 * Goes to the previous linear screen
		 * @return
		 */
		public function gotoPreviousScreen():IScreenVO
		{
			if(! isPreviousScreen()) return undefined;
			var screen:IScreenVO = structureVO.gotoPreviousScreen();
			dispatchScreenChangeSignal();
			return screen;
		}

		/**
		 * Goes to the next linear screen
		 * @return
		 */
		public function gotoNextScreen():IScreenVO
		{
			if(! isNextScreen()) return undefined;
			var screen:IScreenVO = structureVO.gotoNextScreen();
			dispatchScreenChangeSignal();
			return screen;
		}

		/**
		 * Goes directly to the screen with the ID
		 * @param	id
		 * @return
		 */
		public function gotoScreenID(id:String):IScreenVO
		{
			var screen:IScreenVO = structureVO.gotoScreenByID(id);
			dispatchScreenChangeSignal();
			return screen;
		}

		/**
		 * Goes directly to the screen with the ID
		 * @param	id
		 * @return
		 */
		public function getScreenID(id:String):IScreenVO
		{
			var screen:IScreenVO = structureVO.getScreenByID(id);
			return screen;
		}

		/**
		 * Dispatches a common screen change event. Will be picked up and run w/ the OnScreenChangeCommand to update the view/SWFAddress/etc
		 */
		private function dispatchScreenChangeSignal():void
		{
			//_onScreenChangeSignal.dispatch(getCurrentScreen().id);
			ScientiaModelSignals.SCREEN_CHANGE.dispatch(getCurrentScreen().id);
		}

		// ---------------------------------------------------------------------
		//
		// SCREEN DATA
		//
		// ---------------------------------------------------------------------
		/**
		 * Returns a string [page] "X of XX"
		 * TODO, work on module level or whole course level, currently works on module level
		 * @return
		 */
		public function getPageOfTotalPagesString():String
		{
			return (structureVO.getCurrentModuleScreenIndex() + 1) + " of " + structureVO.getCurrentModuleNumScreens();
		}

		// ---------------------------------------------------------------------
		//
		// SCREEN STATUS
		//
		// ---------------------------------------------------------------------
		/**
		 * Sets the status of the screen
		 * @param screenid	ID of the screen
		 * @param status	Status
		 * @param interactionobject	Item level interaction data for the screen
		 */
		public function setScreenIDStatusInteractionObject(screenid:String, status:int, interactionobject:InteractionObject = undefined):void
		{
			Debugger.instance.add("Set screen " + screenid + " to status: " + status, this);

			var screen:IScreenVO = getScreenID(screenid);
			screen.status = status;
			screen.interactionObject = interactionobject;
		}

		/**
		 * Sets the status of the screen and broads a changed signal. Causing the command to run
		 */
		public function setScreenIDStatusInteractionObjectAndBroadcast(screenid:String, status:int, interactionobject:InteractionObject = undefined):void
		{
			setScreenIDStatusInteractionObject(screenid, status, interactionobject);

			ScientiaModelSignals.SCREEN_STATUS_CHANGE.dispatch(screenid);
		}

		/**
		 * Based on the completion criteria, determins if the SCO is complete
		 */
		public function isComplete():Boolean
		{
			switch(configVO.lmsCompletionCriteria)
			{
				case CompletionCriteria.ALL_SCREENS:
				case CompletionCriteria.SCORE:
					return structureVO.areAllModulesCompleted();
					break;
				case CompletionCriteria.FIRST_SCREEN:
				case CompletionCriteria.LAST_SCREEN:
				default:
					Debugger.instance.add("Completion criteria: '" + configVO.lmsCompletionCriteria + "' not supported.", this);
			}
			return false;
		}

		/**
		 * Returns the current score
		 */
		public function getCurrentScorePercentage():int
		{
			var numberOfScoredScreens:int = structureVO.getNumberOfScoredScreens();

			if(numberOfScoredScreens == 0) return 100;

			var numberOfCorrectScreens:int = structureVO.getNumberOfScreensWithStatus(ObjectStatus.PASSED);
			// unused var numberOfWrongScreens:int = structureVO.getNumberOfScreensWithStatus(ObjectStatus.FAILED);

			var scorePecentage:int = (numberOfCorrectScreens / numberOfScoredScreens) * 100;
			return scorePecentage;
		}

		public function isPassing():Boolean
		{
			if(getCurrentScorePercentage() >= configVO.lmsPassingScore) return true;
			return false;
		}

	}
}