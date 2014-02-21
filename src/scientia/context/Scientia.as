package scientia.context
{
	import scientia.controller.commands.ExitSCOCommand;
	import scientia.controller.commands.GoURLCommand;
	import scientia.controller.commands.GotoNextScreenCommand;
	import scientia.controller.commands.GotoPreviousScreenCommand;
	import scientia.controller.commands.GotoScreenIDCommand;
	import scientia.controller.commands.NotifyOnErrorCommand;
	import scientia.controller.commands.RespondToKeyPressCommand;
	import scientia.controller.commands.UpdateOnScreenChangeCommand;
	import scientia.controller.commands.UpdateOnScreenStatusChangeCommand;
	import scientia.controller.commands.startup.InitializeLMSCommand;
	import scientia.controller.commands.startup.StartupCommand;
	import scientia.controller.commands.startup.StartupNoLMSCommand;
	import scientia.controller.commands.startup.StartupWithLMSCommand;
	import scientia.events.signals.NavigationSignals;
	import scientia.events.signals.ScientiaModelSignals;
	import scientia.events.signals.StartupSignals;
	import scientia.model.IModelConfigurationDeserializer;
	import scientia.model.IScientiaModel;
	import scientia.model.ModelConfigurationDeserializer;
	import scientia.model.ScientiaModel;
	import scientia.utils.ILMSUpdater;
	import scientia.utils.LMSUpdater;
	import scientia.view.IScientiaView;
	import scientia.view.ScientiaView;
	import scientia.view.ScreenManager;
	import scientia.view.ScreenManagerMediator;
	import scientia.view.UIView;
	import scientia.view.UIViewMediator;

	import com.asual.ISWFAddress;
	import com.asual.SWFAddress;
	import com.nudoru.components.IWindowManager;
	import com.nudoru.components.WindowManager;
	import com.nudoru.debug.Debugger;
	import com.nudoru.lms.ILMSProtocolFacade;
	import com.nudoru.lms.LMSProtocolFactory;
	import com.nudoru.nori.events.signals.ErrorSignals;
	import com.nudoru.noriplugins.appview.context.AppContext;
	import com.nudoru.services.CookieService;
	import com.nudoru.services.ICookieService;
	import com.nudoru.utilities.AssetsProxy.IAssetsProxy;

	import flash.display.DisplayObject;

	/**
	 * Scentia Screen Player Application built on the Nori Framework
	 * 
	 * @author Matt Perkins
	 * 
	 */
	public class Scientia extends AppContext implements IScientia
	{
		/**
		 * The content loader load the content XML file and provides the model with injectable
		 * ConfigVO, ThemeVO and StructureVO objects
		 */
		private var _modelConfigDeserializer:IModelConfigurationDeserializer;
		/**
		 * MVC Parts
		 */
		private var _model:IScientiaModel;
		private var _view:IScientiaView;
		/**
		 * Common so that the view and screens will share it
		 */
		private var _windowManager:IWindowManager;
		/**
		 * LMS protocols
		 */
		private var _lmsProtocol:ILMSProtocolFacade;
		private var _lmsUpdater:ILMSUpdater;
		/**
		 * Non-LMS tracking methods
		 */
		private var _cookieSvc:ICookieService;
		private var _swfAddress:ISWFAddress;

		// ---------------------------------------------------------------------
		//
		// INITIALIZE
		//
		// ---------------------------------------------------------------------
		public function Scientia():void
		{
			super();
		}

		/**
		 * Starting
		 * 
		 * Steps:
		 *	 AppContext - 1. load the content XML file
		 *	 AppContext - 2. load the assets SWF file
		 * 	 3. assemble
		 * 	 4. dispatch complete signal
		 * 	 5. run called from the outside
		 * 	 6. init LMS and run
		 */
		override protected function onStartUp():void
		{
			_contentXMLFileURL = "content.xml";
			_assetsSWFFileURL = "assets.swf";
			
			super.onStartUp();
		}

		// ---------------------------------------------------------------------
		//
		// 2 CONSTRUCTION
		//
		// ---------------------------------------------------------------------
		override protected function assemble():void
		{
			Debugger.instance.add("SCIENTIA ASSEMBLING",this);
			
			_modelConfigDeserializer = new ModelConfigurationDeserializer();
			_modelConfigDeserializer.process(_contentXMLLoader.content);
			
			_model = new ScientiaModel();
			_view = new ScientiaView();
			_windowManager = new WindowManager();
			_cookieSvc = new CookieService();
			_swfAddress = new SWFAddress();

			mapInjectionPoints();
			mapViewMediators();

			// also run the initialize function via [PostConstruction]
			injector.injectInto(_model);
			injector.injectInto(_view);

			mapCommands();

			_contextView.addChild(_view as DisplayObject);

			// Even if no LMS connection required, Need to create a Null protocol and map values
			initialzeAndMapLMSProtocols();

			// The parent of the context should pick this up and then calls the run() function
			contextInitialzedSignal.dispatch();
		}

		private function mapInjectionPoints():void
		{
			injector.mapValue(IModelConfigurationDeserializer, _modelConfigDeserializer);
			injector.mapValue(IAssetsProxy, _assetsProxy);
			injector.mapValue(IWindowManager, _windowManager);
			injector.mapValue(IScientiaModel, _model);
			injector.mapValue(IScientiaView, _view);
			injector.mapValue(ICookieService, _cookieSvc);
			injector.mapValue(ISWFAddress, _swfAddress);
		}

		private function mapViewMediators():void
		{
			mediatorMap.map(UIView, UIViewMediator);
			mediatorMap.map(ScreenManager, ScreenManagerMediator);
		}

		private function mapCommands():void
		{
			// Startup
			commandMap.mapSignalCommand(StartupSignals.START_UP, StartupCommand);
			commandMap.mapSignalCommand(StartupSignals.INITIALIZE_LMS, InitializeLMSCommand);
			commandMap.mapSignalCommand(StartupSignals.START_UP_LMS, StartupWithLMSCommand);
			commandMap.mapSignalCommand(StartupSignals.START_UP_NO_LMS, StartupNoLMSCommand);

			// Errors
			commandMap.mapSignalCommand(ErrorSignals.ERROR_WARNING, NotifyOnErrorCommand);
			commandMap.mapSignalCommand(ErrorSignals.ERROR_ERROR, NotifyOnErrorCommand);
			commandMap.mapSignalCommand(ErrorSignals.ERROR_FATAL, NotifyOnErrorCommand);

			// General view - these view events are in the AppView not specific to scientia
			commandMap.mapSignalCommand(_view.onStageKeyPressSignal, RespondToKeyPressCommand);

			// Navigation signals
			commandMap.mapSignalCommand(NavigationSignals.GOTO_SCREEN_ID, GotoScreenIDCommand);
			commandMap.mapSignalCommand(NavigationSignals.GOTO_NEXT_SCREEN, GotoNextScreenCommand);
			commandMap.mapSignalCommand(NavigationSignals.GOTO_PREVIOUS_SCREEN, GotoPreviousScreenCommand);
			commandMap.mapSignalCommand(NavigationSignals.GOTO_URL, GoURLCommand);
			commandMap.mapSignalCommand(NavigationSignals.EXIT, ExitSCOCommand);

			// Model signals
			commandMap.mapSignalCommand(ScientiaModelSignals.SCREEN_CHANGE, UpdateOnScreenChangeCommand);
			commandMap.mapSignalCommand(ScientiaModelSignals.SCREEN_STATUS_CHANGE, UpdateOnScreenStatusChangeCommand);
		}

		private function initialzeAndMapLMSProtocols():void
		{
			// configure the LMS protocol if specified
			// need to do it here since the model needs to have the configvo injected before the data is available
			_lmsProtocol = LMSProtocolFactory.createLMSProtocol(_model.configVO.lmsMode);

			// have to map this injector value after the protocol is created
			injector.mapValue(ILMSProtocolFacade, _lmsProtocol);

			_lmsUpdater = new LMSUpdater();

			injector.mapValue(ILMSUpdater, _lmsUpdater);
			injector.injectInto(_lmsUpdater);
		}

		// ---------------------------------------------------------------------
		//
		// 3 RUN
		//
		// ---------------------------------------------------------------------
		override public function run():void
		{
			Debugger.instance.add("SCIENTIA RUNNING",this);
			
			// Startup steps handled via commands in the scientia.controller.commands.startup package
			// Startup without the LMS is in the StartupNoLMSCommand
			// Startup with the LMS is in the StartupWithLMSCommand
			StartupSignals.START_UP.dispatch();
		}
	}
}