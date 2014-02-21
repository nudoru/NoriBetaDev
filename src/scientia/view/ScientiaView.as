package scientia.view
{
	import com.nudoru.components.ComponentTheme;
	import com.nudoru.debug.Debugger;
	import com.nudoru.noriplugins.appview.view.AppView;
	import com.nudoru.utilities.ContextMenuUtils;

	import flash.display.DisplayObject;

	import scientia.events.signals.NavigationSignals;
	import scientia.model.Settings;
	import scientia.model.consts.ScreenType;
	import scientia.model.structure.IScreenVO;

	/**
	 * Extends the app view to provide screen viewing and navigation capabilities
	 * Loads the assets.swf file via the AssetsProxy to help keep the project FLA filesize down.
	 */
	public class ScientiaView extends AppView implements IScientiaView
	{
		private var _ScreenManager:IScreenManager;
		private var _UIView:IUIView;

		// ---------------------------------------------------------------------
		//
		// CONSTRUCTOR/INIT
		//
		// ---------------------------------------------------------------------
		public function ScientiaView()
		{
			super();
		}

		[PostConstruct]
		override public function initialize(data:*=null):void
		{
			super.initialize(data);
		}

		override public function render():void
		{
			// Debugger.instance.add("Screen App view render ...", this);

			super.render();

			setNudoruComponentThemeDefaults();
			createApplicationUIView();
			createScreenManager();
			setAppUIViewStyle(Settings.scaleView);
			this.contextMenu = ContextMenuUtils.createBlankContextMenu();
			adjustApplicationUIToViewSize();

			// Debugger.instance.add("... render completed", this);
		}

		private function setNudoruComponentThemeDefaults():void
		{
			ComponentTheme.highlightColor = Settings.highLightColor;
			ComponentTheme.colors = Settings.themeColors;
		}

		private function createApplicationUIView():void
		{
			_UIView = new UIView();
			_UIView.initialize(getAssetAsMC("siteUI"));
			_UIView.render();
			appUILayer.addChild(_UIView as DisplayObject);
		}

		private function createScreenManager():void
		{
			_ScreenManager = new ScreenManager();
			_ScreenManager.initialize({width:Settings.screenWidth, height:Settings.screenHeight, scroll:false, mask:true, transition:Settings.screenTransition});
			_ScreenManager.render();

			DisplayObject(_ScreenManager).x = Settings.screenXPosition;
			DisplayObject(_ScreenManager).y = Settings.screenYPosition;

			appUILayer.addChild(_ScreenManager as DisplayObject);
		}

		// ---------------------------------------------------------------------
		//
		// UIVIEW
		//
		// ---------------------------------------------------------------------
		
		public function setTitle(text:String):void
		{
			_UIView.setTitle(text);
		}

		public function setPageNumber(text:String):void
		{
			_UIView.setPageNumber(text);
		}

		public function enableBackButton():void
		{
			_UIView.enableBackButton();
		}

		public function disableBackButton():void
		{
			_UIView.disableBackButton();
		}

		public function enableNextButton():void
		{
			_UIView.enableNextButton();
		}

		public function disableNextButton():void
		{
			_UIView.disableNextButton();
		}

		// ---------------------------------------------------------------------
		//
		// SCREENS
		//
		// ---------------------------------------------------------------------
		/**
		 * Show a screen in the ScreenManager
		 * @param screen IScreenVO to show
		 * @param ndirection Navigation direction, -1 back, 0 neutral, 1 forward
		 */
		public function showScreen(screen:IScreenVO, ndirection:int = 0):void
		{
			// Debugger.instance.add("show screen " + screen.id + "[" + screen.type + "]", this);

			if(screen.type == ScreenType.SWF || screen.type == ScreenType.SCREEN)
			{
				_ScreenManager.showScreenSWF(screen, ndirection);
			}
			else if(screen.type == ScreenType.VIEW)
			{
				/*removeCurrentScreen();
				_currentScreenView = getScreenView(screen.screenPath);
				_currentScreenView.initialize(screen);
				_currentScreenView.render();
				_currentScreenView.x = _screenX;
				_currentScreenView.y = _screenY;
				uiAppLayer.addChild(_currentScreenView);*/
				trace("show view: " + screen.screenPath);
			}
			else if(screen.type == ScreenType.URL)
			{
				NavigationSignals.GOTO_URL.dispatch(screen.dataURL);
			}
		}

		// ---------------------------------------------------------------------
		//
		// DESTROY
		//
		// ---------------------------------------------------------------------
		override public function destroy():void
		{
			super.destroy();
		}
	}
}