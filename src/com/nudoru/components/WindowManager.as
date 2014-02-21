package com.nudoru.components
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.nudoru.visual.drawing.Checkerboard;
	
	import flash.display.*;
	import flash.events.*;

	/**
	 * Simple window manager for NudoruWindows
	 * 
	 * Sample:
	
	protected var _SWindowManager:SimpleWindowManager; 
	_SWindowManager = new SimpleWindowManager();
	_SWindowManager.initialize();
	_SWindowManager.render();
	this.addChild(_SWindowManager);
	 
	*/
	public class WindowManager extends AbstractVisualComponent implements IWindowManager
	{
		
		//protected var _windows				:Array = [];
		protected var _windows				:Vector.<IWindow> = new Vector.<IWindow>();
		protected var _animate				:Boolean = true;
		
		protected var _wmanagerLayer		:Sprite;
		protected var _modalMaskLayer		:Sprite;
		protected var _modalMask			:Sprite;
		protected var _windowLayer			:Sprite;
		
		/**
		 * Constructor
		 */
		public function WindowManager()
		{
			super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			_wmanagerLayer = new Sprite();
			_modalMaskLayer = new Sprite();
			_windowLayer = new Sprite();
			
			_wmanagerLayer.addChild(_modalMaskLayer);
			_wmanagerLayer.addChild(_windowLayer);
			this.addChild(_wmanagerLayer);
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}
		
		//---------------------------------------------------------------------------------------------------------------
		// WINDOW
		
		/**
		 * Show a basic window
		 */
		public function showMessage(title:String, message:String, emphasis:Boolean = false, height:int=250, modal:Boolean = false):IWindow
		{
			var window:IWindow = new Window();
			window.initialize({
				width:400,
				height:height,
				bordersize:15,
				title:title,
				content:message,
				font:"Verdana",
				size:12,
				leading:5,
				color:0x000000,
				emphasis:emphasis,
				modal:modal,
				buttons:[Window.closeButton]
			});
			window.render();
			_windowLayer.addChild(window as DisplayObject);
			window.alignStageCenter();
			
			window.addEventListener(ComponentEvent.EVENT_START_DRAG, onWindowStartDrag, false, 0, true);
			window.addEventListener(ComponentEvent.EVENT_STOP_DRAG, onWindowStopDrag, false, 0, true);
			window.addEventListener(ComponentEvent.EVENT_DESTROYED, onWindowDestroy, false, 0, true);
			
			_windows.push(window);
			
			if (_animate) doWindowInAnimation(window as DisplayObject);
			
			showModalMask();
			
			return window;
		}

		/**
		 * Show a custom window
		 */
		public function showMessageCustomWindow(title:String, message:String, winmc:MovieClip, width:int, close:String="", modal:Boolean = false):void
		{
			var window:IWindow = new CustomWindow();
			window.initialize( {
				window:winmc,
				close:close,
				width:width,
				height:200,
				bordersize:7,
				title:title,
				content:message,
				modal:modal
			});
			window.render();
			_windowLayer.addChild(window as DisplayObject);
			window.alignStageCenter();
			
			window.addEventListener(ComponentEvent.EVENT_START_DRAG, onWindowStartDrag, false, 0, true);
			window.addEventListener(ComponentEvent.EVENT_STOP_DRAG, onWindowStopDrag, false, 0, true);
			window.addEventListener(ComponentEvent.EVENT_DESTROYED, onWindowDestroy, false, 0, true);
			
			_windows.push(window);
			
			if (_animate) doWindowInAnimation(window as DisplayObject);
			
			showModalMask();
		}
		
		/**
		 * Animate the windows on to the stage
		 */
		protected function doWindowInAnimation(window:DisplayObject):void
		{
			window.alpha = 0;
			var targetY:int = window.y;
			window.y -= 20;
			applyBlurFilter(window, 20, 20);
			//TweenMax.to(_containerSprite, 0, { colorTransform: { exposure:2 }} );
			TweenMax.to(window,.75,{alpha:1, y:targetY, blurFilter: { blurX:0, blurY:0 }, ease:Expo.easeOut}); 
		}
		
		/**
		 * Handle when a window begins drag
		 */
		protected function onWindowStartDrag(event:ComponentEvent):void
		{
			TweenMax.to(event.target as DisplayObject, .25, { alpha:.85, ease:Quad.easeOut } );
			// bump the window to the top of the display on start drag
			_windowLayer.addChild(event.target as DisplayObject);
		}
		
		/**
		 * Handle when a window stops drag
		 */
		protected function onWindowStopDrag(event:ComponentEvent):void
		{
			//trace("Stop drag: "+event.target);
			TweenMax.to(event.target as DisplayObject, .5, { alpha:1, ease:Quad.easeOut } );
		}
		
		/**
		 * Handles when a window is closed/destroyed
		 */
		protected function onWindowDestroy(event:ComponentEvent):void
		{
			deleteWindow(event.target);
			
			removeModalMask();
		}

		
		//---------------------------------------------------------------------------------------------------------------
		// MODAL MASK
		
		/**
		 * Test for any modal windows
		 * @return	True if any modal windows are in the windows array
		 */
		protected function anyModalWindows():Boolean
		{
			for (var i:int = 0, len:int = _windows.length; i < len; i++)
			{
				if (_windows[i].modal) return true;
			}
			return false;
		}
		
		protected function showModalMask():void
		{
			if (!anyModalWindows() || _modalMask) return;
			createModalMask();
			this.stage.addEventListener(Event.RESIZE, resizeModalOnResize, false, 0, true);
		}
		
		protected function removeModalMask():void
		{
			if (anyModalWindows()) return;
			deleteModalMask();
			this.stage.removeEventListener(Event.RESIZE, resizeModalOnResize);
		}
		
		protected function createModalMask():void
		{
			deleteModalMask();
			
			_modalMask = new Sprite();
			
			_modalMask.graphics.beginFill(ComponentTheme.modalMaskColor, 1);
			_modalMask.graphics.drawRect(0, 0, this.stage.stageWidth, this.stage.stageHeight);
			_modalMask.graphics.endFill();
			
			if (ComponentTheme.texture)
			{
				var texture:Checkerboard = new Checkerboard(1, 0x000000, 0xffffff, this.stage.stageWidth, this.stage.stageHeight);
				texture.alpha = .1;
				texture.blendMode = BlendMode.MULTIPLY;
				_modalMask.addChild(texture);
			}
			
			_modalMask.blendMode = BlendMode.HARDLIGHT;
			_modalMaskLayer.addChild(_modalMask);
		}
		
		protected function deleteModalMask():void
		{
			if (_modalMask)
			{
				_modalMask.graphics.clear();
				_modalMaskLayer.removeChild(_modalMask);
				_modalMask = undefined;
			}
		}
		
		protected function resizeModalOnResize(e:Event):void
		{
			createModalMask();
		}
		
		//---------------------------------------------------------------------------------------------------------------
		// UTILITY
		
		/**
		 * Returns the index of the window from the window list array
		 */
		protected function getWindowArrayIndex(window:*):int
		{
			for(var i:int=0, len:int=_windows.length; i<len;i++)
			{
				if(_windows[i] == window) return i;
			}
			
			return -1;
		}
		
		/**
		 * Gets the window with the highest Z index
		 * @return
		 */
		protected function getHighestZWindow():Window
		{
			return _windowLayer.getChildAt(_windowLayer.numChildren - 1) as Window;
		}
		
		//---------------------------------------------------------------------------------------------------------------
		// DESTROY
		
		/**
		 * Closes the window at the highest Z index
		 */
		public function closeTopWindow():void
		{
			if (!_windows.length) return;
			var topWindow:IWindow = getHighestZWindow();
			
			topWindow.destroy();
			
			//deleteWindow();
		}
		
		/**
		 * Removes all of the windows
		 */
		public function removeAllWindows():void
		{
			for(var i:int=0, len:int=_windows.length; i<len;i++)
			{
				deleteWindow(_windows[i]);
			}
		}
		
		/**
		 * Removes a window from the window list and the display
		 */
		protected function deleteWindow(window:*):void
		{
			var widx:int = getWindowArrayIndex(window);
			if(widx >= 0)
			{
				_windowLayer.removeChild(window);
				_windows.splice(widx,1);
			}
		}
		
		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			if(_windows.length)
			{
				for(var i:int=0,len:int=_windows.length;i<len;i++)
				{
					deleteWindow(_windows[i] as Window);
				}
			}
			
			_wmanagerLayer.removeChild(_modalMaskLayer);
			_wmanagerLayer.removeChild(_windowLayer);
			this.removeChild(_wmanagerLayer);
			
			_modalMaskLayer = null;
			_windowLayer = null;
			_wmanagerLayer = null;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
		
	}
}