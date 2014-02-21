package com.nudoru.noriplugins.appview.view
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.nudoru.components.IWindowManager;
	import com.nudoru.debug.Debugger;
	import com.nudoru.nori.mvc.view.AbstractNoriView;
	import com.nudoru.utilities.AssetsProxy.IAssetsProxy;

	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.text.Font;
	import flash.ui.ContextMenu;

	import net.hires.debug.Stats;

	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	import scientia.model.Settings;

	/**
	 * Main view class for the application view. Provides common functionality
	 * Loads the assets.swf file via the AssetsProxy to help keep the project FLA filesize down.
	 */
	public class AppView extends AbstractNoriView implements IAppView
	{
		// ----------------------------------------------------------------------------------------------------------------------------------
		// Variables
		protected var _debugView:MovieClip;
		protected var _debugStatsView:Stats;
		protected var _appScalableBGMC:MovieClip;
		protected var _appUIView:Sprite;
		protected var _appBGLayer:Sprite;
		protected var _appUILayer:Sprite;
		protected var _assetProxy:IAssetsProxy;
		protected var _WindowManager:IWindowManager;
		protected var _customContextMnu:ContextMenu;
		/**
		 * Horizontal alignment of the app area.
		 * Possible values are: left, center, right
		 */
		protected var _appHorizontalAlign:String = "center";
		/**
		 * Vertical alignment of the app area.
		 * Possible values are: top, middle, bottom
		 */
		protected var _appVerictalAlign:String = "middle";
		// signals available other classes via getters
		protected var _onStageResizeSignal:Signal = new Signal();
		protected var _onStageFocusInSignal:Signal = new Signal();
		protected var _onStageFocusOutSignal:Signal = new Signal();
		protected var _onStageKeyPressSignal:Signal = new Signal(KeyboardEvent);
		// native signals for stage events
		protected var _stageResizeNSignal:NativeSignal;
		protected var _stageFocusInNSignal:NativeSignal;
		protected var _stageFocusOutNSignal:NativeSignal;
		protected var _stageKeyPressNSignal:NativeSignal;

		// ----------------------------------------------------------------------------------------------------------------------------------
		// Getter/Setter
		public function get assetProxy():IAssetsProxy
		{
			return _assetProxy;
		}

		[Inject]
		public function set assetProxy(value:IAssetsProxy):void
		{
			_assetProxy = value;
		}

		public function get windowManager():IWindowManager
		{
			return _WindowManager;
		}

		[Inject]
		public function set windowManager(windowManager:IWindowManager):void
		{
			_WindowManager = windowManager;
		}

		public function get appUIView():Sprite
		{
			return _appUIView;
		}

		public function get appBackgroundLayer():Sprite
		{
			return _appBGLayer;
		}

		public function get appScalableBGMC():MovieClip
		{
			return _appScalableBGMC;
		}

		public function get appUILayer():Sprite
		{
			return _appUILayer;
		}

		public function get appUIWidth():int
		{
			return appUILayer.width;
		}

		public function get appUIHeight():int
		{
			return appUILayer.height;
		}

		public function get viewWidth():int
		{
			return this.stage.stageWidth;
		}

		public function get viewHeight():int
		{
			return this.stage.stageHeight;
		}

		/**
		 * Signals
		 */
		public function get onStageResizeSignal():Signal
		{
			return _onStageResizeSignal;
		}

		public function get onStageFocusInSignal():Signal
		{
			return _onStageFocusInSignal;
		}

		public function get onStageFocusOutSignal():Signal
		{
			return _onStageFocusOutSignal;
		}

		public function get onStageKeyPressSignal():Signal
		{
			return _onStageKeyPressSignal;
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// Initialization
		/**
		 * @protected
		 */
		public function AppView()
		{
			super();
			// don't autowire, since this is the main app view, it'll be injected in the context
			autoWire = false;
		}

		/**
		 * Initialize the view
		 */
		[PostConstruct]
		override public function initialize(data:*=null):void
		{
			// Debugger.instance.add("App view  initialize", this);
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// App stuff
		/**
		 * Post initialization UI rendering
		 */
		override public function render():void
		{
			// Debugger.instance.add("App view render", this);

			createUISignals();
			registerFonts();
			buildAppUI();
			initWindowManager();
			initialzeVisualDebugger();
		}

		protected function setAppUIViewStyle(scale:Boolean):void
		{
			if(scale)
			{
				this.stage.align = StageAlign.TOP;
				this.stage.scaleMode = StageScaleMode.SHOW_ALL;
			}
			else
			{
				this.stage.align = StageAlign.TOP_LEFT;
				this.stage.scaleMode = StageScaleMode.NO_SCALE;
			}
		}

		private function createUISignals():void
		{
			// Native signals to lisent for stage events
			_stageResizeNSignal = new NativeSignal(this.stage, Event.RESIZE, Event);
			_stageFocusInNSignal = new NativeSignal(this.stage, Event.ACTIVATE, Event);
			_stageFocusOutNSignal = new NativeSignal(this.stage, Event.DEACTIVATE, Event);
			_stageKeyPressNSignal = new NativeSignal(this.stage, KeyboardEvent.KEY_DOWN, Event);

			_stageResizeNSignal.add(onWindowResize);
			_stageFocusInNSignal.add(onStageFocusIn);
			_stageFocusOutNSignal.add(onStageFocusOut);
			_stageKeyPressNSignal.add(onKeyPress);
		}

		/**
		 * Builds the sprites and containers neccessary for the view
		 */
		private function buildAppUI():void
		{
			_appUIView = new Sprite();
			_appBGLayer = new Sprite();
			_appUILayer = new Sprite();

			_appUIView.addChild(_appBGLayer);
			_appUIView.addChild(_appUILayer);

			this.addChild(_appUIView);

			_appScalableBGMC = getAssetAsMC("siteBG");

			_appBGLayer.addChild(_appScalableBGMC);
		}

		private function initWindowManager():void
		{
			this.addChild(_WindowManager as DisplayObject);
			_WindowManager.initialize();
			_WindowManager.render();
		}

		/**
		 * Makes the fonts from the assets swf file available in the framework
		 * If the framework is being run as loaded by the loader, the fonts need to be registered in the loader
		 */
		protected function registerFonts():void
		{
			// Debugger.instance.add("Registering fonts ...", this);

			var registerFontsInLoader:Boolean = Object(this.stage.getChildAt(0)).getName() == "NoriLoader";

			for(var i:int = 0, len:int = Settings.assetFonts.length; i < len; i++)
			{
				if(registerFontsInLoader)
				{
					Debugger.instance.add("Adding font in loader: " + Settings.assetFonts[i]);
					Object(this.stage.getChildAt(0)).registerFont(_assetProxy.assetsAppDomain.getDefinition(Settings.assetFonts[i])  as  Class);
				}
				else
				{
					try
					{
						Font.registerFont(_assetProxy.assetsAppDomain.getDefinition(Settings.assetFonts[i])  as  Class);
						Debugger.instance.add("Added font: " + Settings.assetFonts[i]);
					}
					catch (e:*)
					{
						Debugger.instance.add("FAILED to add font: " + Settings.assetFonts[i]);
					}
				}
			}
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// stage focus
		protected function onStageFocusIn(e:Event):void
		{
			_onStageFocusInSignal.dispatch();
		}

		protected function onStageFocusOut(e:Event):void
		{
			_onStageFocusOutSignal.dispatch();
		}

		public function suspendRender():void
		{
			//
		}

		public function resumeRender():void
		{
			//
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// key press
		protected function onKeyPress(e:KeyboardEvent):void
		{
			_onStageKeyPressSignal.dispatch(e);
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// Resizing/centering
		protected function onWindowResize(event:Event):void
		{
			_onStageResizeSignal.dispatch();

			adjustApplicationUIToViewSize(true);
		}

		protected function adjustApplicationUIToViewSize(animate:Boolean = false):void
		{
			appScalableBGMC.scaleX = viewWidth * .01;
			appScalableBGMC.scaleY = viewHeight * .01;

			// default to centered locations
			var tgtX:int = (viewWidth / 2) - (appUIWidth / 2);
			var tgtY:int = (viewHeight / 2) - (appUIHeight / 2);

			if(_appHorizontalAlign == "left") tgtX = 0;
			if(_appHorizontalAlign == "right") tgtX = viewWidth - appUIWidth;
			if(_appVerictalAlign == "top") tgtY = 0;
			if(_appVerictalAlign == "bottom") tgtY = viewHeight - appUIHeight;

			// keep the site from moving off of the stage
			if(tgtX < 0) tgtX = 0;
			if(tgtY < 0) tgtY = 0;

			if(animate)
			{
				TweenMax.to(appUILayer, .5, {x:tgtX, y:tgtY, ease:Expo.easeOut, delay:.25});
			}
			else
			{
				appUILayer.x = tgtX;
				appUILayer.y = tgtY;
			}
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// Message
		/**
		 * Shows a modal message
		 * @param	title
		 * @param	content
		 */
		public function showModalMessage(title:String, content:String):void
		{
			_WindowManager.showMessage(title, content, true, 200, true);
		}

		/**
		 * Shows a message
		 * @param	title
		 * @param	content
		 */
		public function showMessage(title:String, content:String):void
		{
			_WindowManager.showMessage(title, content, false, 200);
		}

		/**
		 * Closes the window with the highest Z order
		 */
		public function closeTopWindow():void
		{
			_WindowManager.closeTopWindow();
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// Debugging
		/**
		 * Initializes visual debugger elements
		 */
		public function initialzeVisualDebugger():void
		{
			_debugView = getAssetAsMC("debugPanel");
			addChild(_debugView);
			_debugView.visible = false;

			Debugger.instance.setOutputField(_debugView.text_txt);
			createStatsDebug();
			hideDebug();
		}

		/**
		 * @protected
		 * Creates the stats debugger and attaches it to the debug trace window
		 */
		protected function createStatsDebug():void
		{
			_debugStatsView = new Stats();
			_debugView.addChild(_debugStatsView);
			_debugStatsView.x = _debugView.width + 1;
		}

		/**
		 * Toggles the visibility of the debugging display
		 */
		public function toggleDebug():void
		{
			if(_debugView.visible) hideDebug();
			else showDebug();
		}

		/**
		 * Shows the debugging display
		 */
		public function showDebug():void
		{
			_debugView.visible = true;
		}

		/**
		 * Hides the debugging display
		 */
		public function hideDebug():void
		{
			_debugView.visible = false;
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// utility
		/**
		 * Returns an exported movieclip from the SWF loaded by the AssetsProxy
		 * @param	linkage	Linkage ID of the exported movieclip
		 * @return	A movieclip from the SWF loaded by the AssetsProxy
		 */
		public function getAssetAsMC(linkage:String):MovieClip
		{
			return _assetProxy[linkage + "_mc"];
		}

		public function getAsset(linkage:String):*
		{
			return _assetProxy[linkage];
		}

		/**
		 * Gets a reference to a named movieclip place directly on the stage of a FLA file
		 * @param	name	Name property of the movieclip on the stage
		 * @return	The movieclip from the stage
		 */
		public function getStageSymbol(name:String):MovieClip
		{
			return DisplayObjectContainer(this.stage.getChildAt(0)).getChildByName(name) as MovieClip;
		}

		/**
		 * Fetches an item from the FLA's library dynamically
		 * 
		 * @param	n	Linkage ID of the item to retreive
		 * @return	Retuns the item from the FLA files library
		 */
		public function getLibrarySymbol(n:String):Object
		{
			var objC:Class = Class(this.loaderInfo.applicationDomain.getDefinition(n));
			var obj:Object = Object(new objC());
			return obj;
		}

		override public function destroy():void
		{
			_appBGLayer.removeChild(_appScalableBGMC);
			_appScalableBGMC = undefined;

			_appUIView.removeChild(_appBGLayer);
			_appUIView.removeChild(_appUILayer);
			this.removeChild(_appUIView);

			_appUIView = undefined;
			_appBGLayer = undefined;
			_appUILayer = undefined;

			_stageResizeNSignal.remove(onWindowResize);
			_stageFocusInNSignal.remove(onStageFocusIn);
			_stageFocusOutNSignal.remove(onStageFocusOut);
			_stageKeyPressNSignal.remove(onKeyPress);

			super.destroy();
		}
	}
}