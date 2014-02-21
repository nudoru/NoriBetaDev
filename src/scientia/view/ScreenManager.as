package scientia.view
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quad;
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.ImageLoader;
	import com.nudoru.components.RadialProgressBar;
	import com.nudoru.debug.Debugger;
	import com.nudoru.nori.events.signals.ErrorSignals;
	import com.nudoru.nori.mvc.view.AbstractNoriView;
	import com.nudoru.utilities.TimeKeeper;
	import com.nudoru.visual.BMUtils;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import org.osflash.signals.Signal;
	import scientia.model.consts.ScreenType;
	import scientia.model.structure.IScreenVO;
	import screen.events.signals.ScreenDisplaySignals;

	/**
	 * Manages and loads screens. Communication with the rest of the Scientia App is handled in the mediator
	 * @author 
	 */
	public class ScreenManager extends AbstractNoriView implements IScreenManager
	{
		// ---------------------------------------------------------------------
		//
		// VARIABLES
		//
		// ---------------------------------------------------------------------
		private var _Width:int;
		private var _Height:int;
		private var _MaskScreen:Boolean;
		private var _ScrollScreen:Boolean;
		private var _Transition:String;
		private var _ScreensHolder:Sprite;
		private var _ScreensMask:Sprite;
		private var _CurrentScreenHolder:Sprite;
		private var _LastScreenBMHolder:Sprite;
		private var _CurrentScreenVO:IScreenVO;
		private var _CurrentNavigationDir:int;
		private var _LastScreenImageBM:Bitmap;
		private var _LastScreenImageBMD:BitmapData;
		/**
		 * Reference to the screen to be loaded
		 */
		private var _QueueScreenVO:IScreenVO;
		private var _ScreenLoader:ImageLoader;
		private var _ProgressBar:RadialProgressBar;
		/**
		 * In the process of loading a screen
		 */
		private var _LoadingScreen:Boolean = false;
		/**
		 * Waiting for a screen to destroy itself
		 */
		private var _WaitingOnUnload:Boolean = false;
		/**
		 * Transition animation running
		 */
		private var _Transitioning:Boolean = false;
		private var _LoadTimer:TimeKeeper;
		private var _onScreenShowSignal:Signal = new Signal(IScreenVO);
		private var _onScreenLoadBeginSignal:Signal = new Signal();
		private var _onScreenLoadedSignal:Signal = new Signal();
		private var _onScreenLoadErrorSignal:Signal = new Signal();
		private var _onScreenInitializedSignal:Signal = new Signal();
		private var _onScreenRenderedSignal:Signal = new Signal();
		private var _onScreenUnloadedSignal:Signal = new Signal();

		// ---------------------------------------------------------------------
		//
		// GETTER/SETTERS
		//
		// ---------------------------------------------------------------------
		public function get onScreenShowSignal():Signal
		{
			return _onScreenShowSignal;
		}

		public function get onScreenLoadBeginSignal():Signal
		{
			return _onScreenLoadBeginSignal;
		}

		public function get onScreenLoadedSignal():Signal
		{
			return _onScreenLoadedSignal;
		}

		public function get onScreenLoadErrorSignal():Signal
		{
			return _onScreenLoadErrorSignal;
		}

		public function get onScreenInitializedSignal():Signal
		{
			return _onScreenInitializedSignal;
		}

		public function get onScreenRenderedSignal():Signal
		{
			return _onScreenRenderedSignal;
		}

		public function get onScreenUnloadedSignal():Signal
		{
			return _onScreenUnloadedSignal;
		}

		/**
		 * Is there currently a screen showing
		 */
		public function get isShowingScreen():Boolean
		{
			if(_CurrentScreenHolder.numChildren) return true;
			return false;
		}

		public function get currentLoadedScreen():Object
		{
			return _ScreenLoader.content;
		}

		// ---------------------------------------------------------------------
		//
		// CONSTRUCTION/INITIALIZATION
		//
		// ---------------------------------------------------------------------
		public function ScreenManager():void
		{
			super();
		}

		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void
		{
			_Width = data.width;
			_Height = data.height;

			_MaskScreen = data.mask;
			_ScrollScreen = data.scroll;

			_Transition = data.transition;

			_LoadTimer = new TimeKeeper("screen_manager_load_timer");
		}

		/**
		 * Draw the view
		 */
		override public function render():void
		{
			_ScreensHolder = new Sprite();
			_ScreensMask = new Sprite();
			_CurrentScreenHolder = new Sprite();
			_LastScreenBMHolder = new Sprite();

			_ScreensHolder.addChild(_CurrentScreenHolder);
			_ScreensHolder.addChild(_LastScreenBMHolder);

			this.addChild(_ScreensHolder);
			this.addChild(_ScreensMask);

			if(_MaskScreen)
			{
				_ScreensMask.graphics.beginFill(0xff0000);
				_ScreensMask.graphics.drawRect(0, 0, _Width, _Height);
				_ScreensMask.graphics.endFill();
				_ScreensHolder.mask = _ScreensMask;
			}

			_ProgressBar = new RadialProgressBar();
			_ProgressBar.x = int((_Width / 2) - 20);
			_ProgressBar.y = int((_Height / 2) - 20);
			_ProgressBar.initialize({radius:20, size:5, barcolor:0xdddddd, progress:0, border:-2});
			_ProgressBar.segments = 30;
			_ProgressBar.render();
			_ProgressBar.visible = false;
			_ProgressBar.alpha = 0;

			this.addChild(_ProgressBar);
		}

		/**
		 * Display a screen, either a SWF or a screen interaction
		 * @param	screen	Screen to load
		 * @param	ndirection	Direction of the navigation, next, back or none
		 */
		public function showScreenSWF(screen:IScreenVO, ndirection:int = 0):void
		{
			// notifies the mediator of the current screen
			_onScreenShowSignal.dispatch(screen);

			_CurrentNavigationDir = ndirection;

			_QueueScreenVO = screen;

			// clean up if in the middle of a page-page transition
			if(_Transitioning)
			{
				TweenMax.killTweensOf(_LastScreenBMHolder, true);
				finalizeScreenTransition();
			}

			// clean up if a screen is still in the process of unloading
			if(_WaitingOnUnload) finalizeScreenRemoval(false);

			// clean up if still loading a screen
			if(_LoadingScreen)
			{
				_ScreenLoader.removeEventListener(ComponentEvent.EVENT_PROGRESS, onScreenSWFLoadProgress);
				_ScreenLoader.removeEventListener(ComponentEvent.EVENT_LOADED, onScreenSWFLoaded);
				_ScreenLoader.removeEventListener(ComponentEvent.EVENT_IOERROR, onScreenSWFError);
				_ScreenLoader.destroy();
				_ScreenLoader = undefined;
			}

			if(screen.type == ScreenType.SWF) showSWF(screen);
			else if(screen.type == ScreenType.SCREEN) showScreen(screen);
		}

		// ---------------------------------------------------------------------
		//
		// SWF SCREEN
		//
		// ---------------------------------------------------------------------
		/**
		 * Show a SWF as a screen
		 * @param	screen
		 */
		private function showSWF(screen:IScreenVO):void
		{
			// Debugger.instance.add("ScreenManager show SWF: " + screen.screenPath);

			removeCurrentScreenSWF();

			_CurrentScreenVO = screen;

			showPreloader();

			_LoadTimer.start();

			_onScreenLoadBeginSignal.dispatch();

			_ScreenLoader = new ImageLoader();
			_ScreenLoader.initialize({url:screen.screenPath});
			_ScreenLoader.addEventListener(ComponentEvent.EVENT_PROGRESS, onScreenSWFLoadProgress, false, 0, true);
			_ScreenLoader.addEventListener(ComponentEvent.EVENT_LOADED, onScreenSWFLoaded, false, 0, true);
			_ScreenLoader.addEventListener(ComponentEvent.EVENT_IOERROR, onScreenSWFError, false, 0, true);
			_ScreenLoader.load();
		}

		// ---------------------------------------------------------------------
		//
		// INTERACTION SCREEN
		//
		// ---------------------------------------------------------------------
		/**
		 * Show an interaction as a screen
		 * If there is a Screen showing, it must destroy itself before the new screen can begin loading.
		 * The event handler for the screen's EVENT_UNLOADED event will call back showScreen with the queued screenvo
		 * @param	screen
		 */
		private function showScreen(screen:IScreenVO):void
		{
			// Debugger.instance.add("ScreenManager show screen: " + screen.id);

			if(isShowingScreen)
			{
				if(_CurrentScreenVO.type == ScreenType.SCREEN)
				{
					_WaitingOnUnload = true;
					removeCurrentScreenSWF();
					return;
				}
				else
				{
					removeCurrentScreenSWF();
				}
			}

			_CurrentScreenVO = screen;

			showPreloader();

			_LoadTimer.start();

			_onScreenLoadBeginSignal.dispatch();

			_ScreenLoader = new ImageLoader();
			_ScreenLoader.initialize({url:screen.screenPath});
			_ScreenLoader.addEventListener(ComponentEvent.EVENT_PROGRESS, onScreenSWFLoadProgress, false, 0, true);
			_ScreenLoader.addEventListener(ComponentEvent.EVENT_LOADED, onScreenSWFLoaded, false, 0, true);
			_ScreenLoader.addEventListener(ComponentEvent.EVENT_IOERROR, onScreenSWFError, false, 0, true);
			_ScreenLoader.load();
		}

		/**
		 * Remove a screen
		 */
		private function removeCurrentScreen():void
		{
			_ScreenLoader.content.destroy();
		}

		/**
		 * Screen has unloaded/destroyed
		 * @param	showQueue
		 */
		private function finalizeScreenRemoval(showQueue:Boolean = true):void
		{
			removeScreenDispalyEvents();

			unloadCurrentScreenSWF();

			_WaitingOnUnload = false;

			// call back with the queued screen
			if(showQueue) showScreen(_QueueScreenVO);
		}

		/**
		 * Adds events to handle screen events
		 */
		private function addScreenDispalyEvents():void
		{
			ScreenDisplaySignals.INITIALIZED.add(onScreenDisplayInitialized);
			ScreenDisplaySignals.RENDERED.add(onScreenDisplayRendered);
			ScreenDisplaySignals.UNLOADED.add(onScreenDisplayUnloaded);
		}

		/**
		 * Fired when the screen's XML has been loaded and parsed
		 * @param	e
		 */
		private function onScreenDisplayInitialized():void
		{
			_onScreenInitializedSignal.dispatch();
		}

		/**
		 * Fired when the screen's been rendered
		 * @param	e
		 */
		private function onScreenDisplayRendered():void
		{
			_onScreenRenderedSignal.dispatch();
		}

		/**
		 * Fires after everything has been destroyed
		 * @param	e
		 */
		private function onScreenDisplayUnloaded():void
		{
			// trace("screen unloaded");
			finalizeScreenRemoval();
		}

		/**
		 * Removes events to handle screen events
		 */
		private function removeScreenDispalyEvents():void
		{
			ScreenDisplaySignals.INITIALIZED.remove(onScreenDisplayInitialized);
			ScreenDisplaySignals.RENDERED.remove(onScreenDisplayRendered);
			ScreenDisplaySignals.UNLOADED.remove(onScreenDisplayUnloaded);
		}

		// ---------------------------------------------------------------------
		//
		// SWF AND INTERACTION COMMON
		//
		// ---------------------------------------------------------------------
		/**
		 * A SWF screen has finished loading
		 * @param	event
		 */
		private function onScreenSWFLoaded(event:Event):void
		{
			hidePreloader();
			_CurrentScreenHolder.addChild(_ScreenLoader.content);

			if(_CurrentScreenVO.type == ScreenType.SCREEN)
			{
				addScreenDispalyEvents();
				// _ScreenLoader.content.initialize( { xmlurl:_CurrentScreenVO.dataURL } );
			}

			_LoadTimer.stop();
			Debugger.instance.add("Screen loaded in " + _LoadTimer.elapsedTimeFormattedMMSS(), this);

			transitionScreens();

			_onScreenLoadedSignal.dispatch();
		}

		/**
		 * Update progress based on Screen Loader
		 * @param	event
		 */
		private function onScreenSWFLoadProgress(event:ComponentEvent):void
		{
			_ProgressBar.progress = event.data;
		}

		/**
		 * Error loading the screen
		 * @param	event
		 */
		private function onScreenSWFError(event:Event):void
		{
			Debugger.instance.add("ERROR: " + event.type, this);
			hidePreloader();
			_ScreenLoader.destroy();
			_ScreenLoader = undefined;

			ErrorSignals.ERROR_ERROR.dispatch({type:ErrorSignals.ERROR_TYPE_ERROR, source:this, message:"Couldn't load the screen: " + _CurrentScreenVO.screenPath + "<br><br>" + event});
		}

		/**
		 * Removes/unload any current screen
		 */
		private function removeCurrentScreenSWF():void
		{
			if(! _CurrentScreenHolder.numChildren) return;

			// take a bitmap image of it for the transition
			captureImageOfCurrent();

			if(_CurrentScreenVO.type == ScreenType.SCREEN)
			{
				removeCurrentScreen();
			}
			else
			{
				unloadCurrentScreenSWF();
			}
		}

		/**
		 * Removes the loaded screen
		 */
		private function unloadCurrentScreenSWF():void
		{
			_CurrentScreenHolder.removeChildAt(0);
			_ScreenLoader.destroy();
			_ScreenLoader = undefined;
			_CurrentScreenVO = undefined;
			_onScreenUnloadedSignal.dispatch();
		}

		// ---------------------------------------------------------------------
		//
		// TRANSITION
		//
		// ---------------------------------------------------------------------
		/**
		 * Create a bitmap copy of the current screen for the transition
		 */
		private function captureImageOfCurrent():void
		{
			disposeImageOfCurrent();
			// trace("captureImageOfCurrent()");
			_LastScreenImageBMD = BMUtils.getBitmapdDataCopy(_CurrentScreenHolder, 0, 0, _Width, _Height);
			_LastScreenImageBM = new Bitmap(_LastScreenImageBMD, "auto", true);
			_LastScreenBMHolder.addChild(_LastScreenImageBM);

			_LastScreenBMHolder.x = 0;
			_LastScreenBMHolder.y = 0;
			_LastScreenBMHolder.alpha = 1;
			_LastScreenBMHolder.scaleX = 1;
			_LastScreenBMHolder.scaleY = 1;

			TweenMax.killTweensOf(_LastScreenBMHolder);
			TweenMax.to(_LastScreenBMHolder, 0, {colorMatrixFilter:{saturation:1}});
			TweenMax.to(_LastScreenBMHolder, 5, {colorMatrixFilter:{saturation:.25}});
		}

		/**
		 * Remove the image of the last screen
		 */
		private function disposeImageOfCurrent():void
		{
			if(_LastScreenImageBMD)
			{
				// trace("disposeImageOfCurrent()");
				_LastScreenImageBMD.dispose();
				_LastScreenBMHolder.removeChild(_LastScreenImageBM);
				_LastScreenImageBM = undefined;
				_LastScreenImageBMD = undefined;
			}
			TweenMax.killTweensOf(_LastScreenBMHolder);
		}

		/**
		 * Transition the screens
		 */
		private function transitionScreens():void
		{
			if(_LastScreenImageBM)
			{
				// trace("transitionScreens() "+ _Transition);
				_Transitioning = true;
				switch(_Transition)
				{
					case ScreenTransitionType.SLIDE:
						transitionSlideIn();
						break;
					case ScreenTransitionType.SQUEEZE:
						transitionSqueezeIn();
						break;
					case ScreenTransitionType.XFADE_SLOW:
						transitionFadeIn(ScreenTransitionType.DUR_SLOW);
						break;
					default:
						transitionFadeIn(ScreenTransitionType.DUR_QUICK);
						break;
				}
			}
		}

		/**
		 * Default transition
		 * @param	dur
		 */
		private function transitionFadeIn(dur:Number = 1):void
		{
			TweenMax.to(_LastScreenBMHolder, dur, {alpha:0, ease:Quad.easeOut, onComplete:finalizeScreenTransition});
		}

		/**
		 * Slide the page in
		 */
		private function transitionSlideIn():void
		{
			var opX:int = _Width * -1;
			var npX:int = _Width;
			if(_CurrentNavigationDir == ScreenTransitionType.DIR_BACK)
			{
				opX = _Width;
				npX = _Width * -1;
			}
			else if(_CurrentNavigationDir == ScreenTransitionType.DIR_NONE)
			{
				transitionFadeIn(ScreenTransitionType.DUR_QUICK);
				return;
			}
			_CurrentScreenHolder.x = npX;
			TweenMax.to(_CurrentScreenHolder, ScreenTransitionType.DUR_MEDIUM, {x:0, ease:Quad.easeOut, onComplete:finalizeScreenTransition});
			if(_LastScreenBMHolder) TweenMax.to(_LastScreenBMHolder, ScreenTransitionType.DUR_MEDIUM, {x:opX, ease:Quad.easeOut});
		}

		/**
		 * Squeeze last page out
		 */
		private function transitionSqueezeIn():void
		{
			var opX:int = 0;
			var npX:int = _Width;
			if(_CurrentNavigationDir == ScreenTransitionType.DIR_BACK)
			{
				opX = _Width;
				npX = 0;
			}
			else if(_CurrentNavigationDir == ScreenTransitionType.DIR_NONE)
			{
				transitionFadeIn(ScreenTransitionType.DUR_QUICK);
				return;
			}
			_CurrentScreenHolder.scaleX = 0;
			_CurrentScreenHolder.x = npX;
			TweenMax.to(_CurrentScreenHolder, ScreenTransitionType.DUR_MEDIUM, {scaleX:1, x:0, ease:Quad.easeOut, onComplete:finalizeScreenTransition});
			if(_LastScreenBMHolder) TweenMax.to(_LastScreenBMHolder, ScreenTransitionType.DUR_MEDIUM, {x:opX, scaleX:0, ease:Quad.easeOut});
		}

		/**
		 * Remove the bitmap image
		 */
		private function finalizeScreenTransition():void
		{
			_Transitioning = false;
			disposeImageOfCurrent();
		}

		// ---------------------------------------------------------------------
		//
		// UTILITY
		//
		// ---------------------------------------------------------------------
		/**
		 * Show the preloader
		 */
		private  function showPreloader():void
		{
			_LoadingScreen = true;
			TweenMax.to(_ProgressBar, .25, {autoAlpha:1, ease:Expo.easeOut});
		}

		/**
		 * Hide the preloader
		 */
		private  function hidePreloader():void
		{
			_LoadingScreen = false;
			TweenMax.to(_ProgressBar, .25, {autoAlpha:0, ease:Expo.easeIn});
		}

		// ---------------------------------------------------------------------
		//
		// DESTROY
		//
		// ---------------------------------------------------------------------
		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			removeCurrentScreenSWF();

			_ProgressBar.destroy();
			this.removeChild(_ProgressBar);
			_ProgressBar = undefined;

			_ScreensHolder.removeChild(_CurrentScreenHolder);
			_ScreensHolder.removeChild(_LastScreenBMHolder);

			_ScreensHolder.mask = undefined;

			this.removeChild(_ScreensHolder);
			this.removeChild(_ScreensMask);

			_ScreensHolder = undefined;
			_ScreensMask = undefined;
			_CurrentScreenHolder = undefined;
			_LastScreenBMHolder = undefined;
		}
	}
}