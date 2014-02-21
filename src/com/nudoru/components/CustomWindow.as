package com.nudoru.components 
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.nudoru.visual.BMUtils;
	import flash.text.*;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * Custom Window
	 * This class may need to be tweaked/changed depending on the desired custom window
	 * 
	 * Sample:
	 * 
		var custwindow:NudoruCustomWindow = new NudoruCustomWindow();
		custwindow.initialize({
			window:new CustomWindow(),
			width:400,
			height:140,
			bordersize:5,
			title:"Window title",
			content:"It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English."
		});
		custwindow.render();
		this.addChild(custwindow);
		custwindow.alignStageCenter();
		
		//IAbstractVisualComponent
	 */
	public class CustomWindow extends AbstractVisualComponent implements IAbstractVisualComponent, IWindow
	{
		
		protected var _width					:int;
		protected var _height					:int;
		protected var _title					:String;
		protected var _content					:String;
		
		protected var _window					:MovieClip;
		protected var _closeLocation			:String;
		
		protected var _components				:Array = [];
		
		protected var _container				:Sprite;
		protected var _handle					:Sprite;
		
		protected var _borderSize				:int = 5;
		
		protected var _titleBarSize				:int = 20;
		
		protected var _modal					:Boolean = false;
		protected var _draggable				:Boolean = true;
		
		/**
		 * This special button data closes the window
		 */
		protected var _closeData				:String = "__close__";
		
		public static var CLOSE_BOTTOM			:String = "close_bottom";
		public static var CLOSE_TOP_RIGHT		:String = "close_top_right";
		
		public function get windowType():String
		{
			return "custom";
		}
		
		public function get modal():Boolean { return _modal; }
		
		/**
		 * Constructor
		 */
		public function CustomWindow():void
		{
			super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			_width = int(data.width);
			_height = int(data.height);
			
			_title = data.title;
			_content = data.content;
			_borderSize = data.bordersize;
			
			_window = data.window;
			_closeLocation = data.close;
			
			_modal = isBool(data.modal);
		
			if (!_borderSize) _borderSize = 5;

			if (!_closeLocation) _closeLocation = CustomWindow.CLOSE_BOTTOM;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			_container = new Sprite();
			_handle = new Sprite();
			_container.addChild(_window);
			_container.addChild(_handle);
			this.addChild(_container);
			
			// draw the title area
			_window.titlebar_mc.scaleX = _width * .01;
			
			if (_title)
			{
				_window.title_txt.width = _width - (_borderSize * 2);
				_window.title_txt.x = _window.title_txt.y = _borderSize;
				setTextField(_window.title_txt, _title);
				// -5 here corrects for the extra height that's applied to the TF with the height is "fixed"
				_window.titlebar_mc.scaleY = (_window.title_txt.height + (_borderSize * 2) - 5) * .01;
			}
			else
			{
				_window.title_txt.visible = false;
				_window.title_txt.x = _window.title_txt.y = 0;
				_window.title_txt.height = 0;
				_window.titlebar_mc.scaleY = _titleBarSize * .01;
			}

			// draws a drag handle
			var handleWidth:int = _window.titlebar_mc.width;
			if (_closeLocation == CustomWindow.CLOSE_TOP_RIGHT) handleWidth = _width - (_borderSize*2) - _window.x_btn.width;
			_handle.graphics.beginFill(0xff0000, 0);
			_handle.graphics.drawRect(0, 0, handleWidth, _window.titlebar_mc.height);
			_handle.graphics.endFill();
			
			// draws the content text
			_window.text_txt.width = _width - (_borderSize * 2);
			_window.text_txt.x = _borderSize;
			_window.text_txt.y = _window.titlebar_mc.height + _borderSize;
			setTextField(_window.text_txt, _content);

			var windowHeight:int = int(_window.text_txt.height) + _window.text_txt.y + _borderSize;
			
			// draws the close button
			if (_closeLocation == CustomWindow.CLOSE_BOTTOM)
			{
				_window.x_btn.visible = false;
				_window.close_btn.useHandCursor = true;
				_window.close_btn.x = int((_width/2)-(_window.close_btn.width/2));
				_window.close_btn.y = int(_window.text_txt.height) + _window.text_txt.y + _borderSize;
				_window.close_btn.addEventListener(MouseEvent.CLICK, onCloseClick, false, 0, true);
				windowHeight = (_window.close_btn.y + _window.close_btn.height + (_borderSize * 2));
			} 
			else 
			{
				_window.close_btn.visible = false;
				_window.x_btn.useHandCursor = true;
				_window.x_btn.x = _width - _borderSize - _window.x_btn.width;
				_window.x_btn.y = int((_window.titlebar_mc.height/2)-(_window.x_btn.height/2));
				_window.x_btn.addEventListener(MouseEvent.CLICK, onCloseClick, false, 0, true);
			}
			// draw the bg
			_window.bg_mc.scaleX = _width * .01;
			_window.bg_mc.scaleY = windowHeight * .01;
			
			BMUtils.applyDropShadowFilter(_container, 5, 45, 0x000000, .50, 20, 1);
			
			if (_draggable) setDraggable();
			
			excludeFromAccessibility(_handle);
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}
		
		protected function setTextField(tf:TextField, text:String, align:String = TextFieldAutoSize.LEFT):void
		{
			tf.autoSize = align;
			tf.wordWrap = true;
			tf.multiline = true;
			tf.selectable = false;
			tf.embedFonts = true;
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.gridFitType = GridFitType.PIXEL;
			
			tf.htmlText = text;
			
			// BUG/HACK? Can't get the textfield's height unless I first access it, don't know why flash isn't updating
			if(tf.height) {}
			
			//Possible fixes for random issues from here: 
			// http://play.blog2t.net/fixing-jumpy-htmltext-links/
			// http://destroytoday.com/blog/2008/08/workaround-001-actionscripts-autosize-bug/
			var tfheight:Number = tf.height;
			tf.autoSize = TextFieldAutoSize.NONE;
			tf.height = tfheight +tf.getTextFormat().leading + 1;
		}
		
		/**
		 * Handles a click event from a button
		 * @param	event
		 */
		protected function onCloseClick(event:MouseEvent):void
		{
			destroy();
		}

		/**
		 * Make the window draggable
		 */
		public function setDraggable():void
		{	
			_handle.buttonMode = true;
			_handle.addEventListener(MouseEvent.MOUSE_DOWN, onHandleDown, false, 0, true);
			_handle.addEventListener(MouseEvent.MOUSE_UP, onHandleUp, false, 0, true);
		}
		
		/**
		 * Start dragging
		 * @param	event
		 */
		protected function onHandleDown(event:Event):void
		{
			_container.startDrag();
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_START_DRAG));
		}
		
		/**
		 * Stop dragging
		 * @param	event
		 */
		protected function onHandleUp(event:Event):void
		{
			_container.stopDrag();
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_STOP_DRAG));
		}
		
		/**
		 * Remove draggability
		 */
		public function removeDraggable():void
		{
			_handle.buttonMode = false;
			_handle.removeEventListener(MouseEvent.MOUSE_DOWN, onHandleDown);
			_handle.removeEventListener(MouseEvent.MOUSE_UP, onHandleUp);
		}
		
		/**
		 * Adds another NudoruComponent to the window
		 * Sample:
		 * 	window.addComponent(NudoruGraphic, {url:"assets/testimage.jpg",  width:250, height:250, border:Border.OUTLINE_J, bordersize:10, bordercolors:[0xcccccc, 0x00ff00]}, 300, 50);
		 * @param	component
		 * @param	initObj
		 * @param	x
		 * @param	y
		 */
		public function addComponent(component:*, initObj:Object, x:int, y:int):void
		{
			var comp:* = new component();
			comp.initialize(initObj);
			comp.render();
			comp.x = x;
			comp.y = y;
			_container.addChild(comp);
			_components.push(comp);
		}
		
		/**
		 * Centers the window in the center of the stage
		 */
		public function alignStageCenter():void
		{
			this.x = int((this.stage.stageWidth/2)-(this.width/2))
			this.y = int((this.stage.stageHeight/2)-(this.height/2))
		}
		
		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			if (_draggable) removeDraggable();

			if (_components)
			{
				for (var ci:int = 0, clen:int = _components.length; ci < clen; ci++)
				{
					_components[ci].destroy();
					_container.removeChild(_components[ci]);
					_components[ci] = null;
				}
				_components = [];
			}
			
			_window.close_btn.removeEventListener(MouseEvent.CLICK, onCloseClick);
			
			_container.removeChild(_handle);
			_container.removeChild(_window);
			_handle = null;
			_window = null;
			this.removeChild(_container);

			_container = null;

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
		
		
	}

}