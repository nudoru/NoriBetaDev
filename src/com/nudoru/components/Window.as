package com.nudoru.components 
{
	import com.nudoru.utilities.AccUtilities;
	import com.nudoru.visual.BMUtils;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * Window
	 * 
	 * Sample:
	 * 
		var window:NudoruWindow = new NudoruWindow();
		window.initialize({
						  width:400,
						  height:250,
						  bordersize:15,
						  title:"Window title",
						  content:"It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).",
						  font:"Verdana",
						  size:12,
						  leading:5,
						  color:0x000000,
						  buttons:[NudoruWindow.closeButton,{label:"Dummy", data:"dummy"}]
						  });
		window.render();
		window.x = 100,
		window.y = 100;
		this.addChild(window);

		window.addEventListener(NudoruComponentEvent.EVENT_CLICK, onWindowEvent);

		function onWindowEvent(event:NudoruComponentEvent):void
		{
			trace("data from window: "+event.data);
		}
	 */
	public class Window extends AbstractVisualComponent implements IAbstractVisualComponent, IWindow
	{
		
		protected var _width					:int;
		protected var _height					:int;
		protected var _title					:String;
		protected var _content					:String;
		protected var _fontName					:String;
		protected var _fontSize					:int;
		protected var _fontColor				:int;
		protected var _fontLeading				:int;
		protected var _titleFontColor			:Number = 0x333333;
		
		protected var _emphasis					:Boolean;
		
		protected var _buttonsData				:Array = [];
		protected var _buttonWidth				:int = 100;
		protected var _buttons					:Array = [];
		protected var _components				:Array = [];
		
		protected var _container				:Sprite;
		protected var _background				:Sprite;
		protected var _contentArea				:Sprite;
		protected var _handle					:Sprite;
		protected var _buttonArea				:Sprite;
		
		protected var _titleTB					:TextBox;
		protected var _contentTB				:TextBox;
		
		protected var _borderSize				:int = 10;
		protected var _titleAreaHeight			:int = 15;
		protected var _buttonAreaHeight			:int = 40;
		
		protected var _modal					:Boolean = false;
		
		protected var _draggable				:Boolean = true;
		
		/**
		 * This special button data closes the window
		 */
		protected var _closeData				:String = "__close__";
		
		/**
		 * Gets the object tag for a close button
		 */
		public static function get closeButton():Object
		{
			return { label:"Close", data:"__close__" };
		}
		
		public function get windowType():String
		{
			return "nudoruwindow";
		}
		
		public function get modal():Boolean { return _modal; }
		
		/**
		 * Constructor
		 */
		public function Window():void
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
			
			_buttonsData = data.buttons;
			
			_emphasis = isBool(data.emphasis);
			
			_modal = isBool(data.modal);
			
			_fontName = data.font;
			_fontSize = int(data.size);
			_fontColor = int(data.color);
			_fontLeading = int(data.leading);
			
			// if no buttons are specified, ensure the close button is added
			if (!_buttonsData) _buttonsData = [ closeButton ];
			if (!_borderSize) _borderSize = 5;
			if (!_fontName) _fontName = ComponentTheme.fontName;
			if (!_fontSize) _fontSize = ComponentTheme.fontSize;
			if (!_fontColor) _fontColor = ComponentTheme.fontColor;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			_container = new Sprite();
			_background = new Sprite();
			_contentArea = new Sprite();
			_handle = new Sprite();
			_buttonArea = new Sprite();
	
			_background = drawGutter(0, 0, _width, _height);
			_contentArea = drawHandle(0, 0, _width, (_height - _buttonAreaHeight), ComponentTheme.radius, 0xeeeeee);
			
			_container.addChild(_background);
			_container.addChild(_contentArea);
			_container.addChild(_buttonArea);
			
			// draws the title text
			if (_title)
			{
				_titleTB = new TextBox();
				_titleTB.initialize({
							width:_width - (_borderSize*2),
							content:_title,
							font:_fontName,
							align:"center",
							size:_fontSize+2,
							color:_titleFontColor
							});
				_titleTB.render();
				_titleTB.x = _borderSize;
				_titleTB.y = _borderSize;
				_titleTB.addPopShadow(),
				_container.addChild(_titleTB);
				_titleAreaHeight = _titleTB.textHeight + (_borderSize*2);
			}
			
			// draws the content text
			if (_content)
			{
				_contentTB = new TextBox();
				_contentTB.initialize({
							width:_width - (_borderSize * 2),
							height:(_height - _buttonAreaHeight - _titleAreaHeight-_borderSize),
							content:_content,
							font:_fontName,
							align:"left",
							size:_fontSize,
							color:_fontColor,
							leading:_fontLeading,
							scroll:true
							});
				_contentTB.render();
				_contentTB.x = _borderSize;
				_contentTB.y = _titleAreaHeight;
				_container.addChild(_contentTB);
			}
			
			// draws a drag handle
			_handle.graphics.beginFill(0xff0000, 0);
			_handle.graphics.drawRect(0, 0, _width, _titleAreaHeight);
			_handle.graphics.endFill();
			_container.addChild(_handle);
			
			// creates the buttons
			if (_buttonsData) 
			{
				renderButtons();
				_buttonArea.y = _height -_buttonAreaHeight + int((_buttonAreaHeight/2)-(_buttons[0].measure().height/2));
				_buttonArea.x = int((_width / 2) - (_buttonArea.width / 2));
			}
			
			if (_emphasis) _container.addChild(drawOutline(0, 0, _width, _height, -1, ComponentTheme.highlightColor));
				else _container.addChild(drawOutline(0, 0, _width, _height,-1,ComponentTheme.handleColor));
			_container.addChild(drawOutline(0, 0, _width, _height));
			
			this.addChild(_container);
			
			BMUtils.applyDropShadowFilter(_container, 5, 45, 0x000000, .50, 20, 1);
			
			if (_draggable) setDraggable();
			
			excludeFromAccessibility(_handle);
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		protected function renderButtons():void
		{
			var btnX:int = 0;
			var btnXSpc:int = 10;
			
			for (var i:int = 0, len:int = _buttonsData.length; i < len; i++)
			{

				var button:Button = new Button();
				button.initialize({
							width:_buttonWidth,
							label:_buttonsData[i].label,
							showface:true,
							font:_fontName,
							size:_fontSize-2,
							color:0x333333,
							bordersize:5
							});
				// when the button is clicked this data will be passed to the window and then redispatched as a click event
				button.data = _buttonsData[i].data;
				button.render();
				button.x = btnX;
				button.y = 0;
				
				button.tabIndex = AccUtilities.tabCounter++;
				
				button.addEventListener(ComponentEvent.EVENT_CLICK, onButtonClick, false, 0, true);
				
				_buttonArea.addChild(button);
				_buttons.push(button);
				
				btnX += _buttonWidth + btnXSpc;
			}
		}
		
		/**
		 * Handles a click event from a button
		 * If the event.data is the "magic" close string, the window is closed if not it's dispatched so listeners to the window get it
		 * @param	event
		 */
		protected function onButtonClick(event:ComponentEvent):void
		{
			if (event.data == _closeData) destroy();
				else dispatchClickEvent(event.data);
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
			this.x = int((this.stage.stageWidth/2)-(_width/2));
			this.y = int((this.stage.stageHeight/2)-(_height/2));
		}
		
		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			if (_draggable) removeDraggable();
			
			if (_titleTB)
			{
				_container.removeChild(_titleTB);
				_titleTB.destroy();
				_titleTB = null;
			}
			
			if (_contentTB)
			{
				_container.removeChild(_contentTB);
				_contentTB.destroy();
				_contentTB = null;
			}
			
			if (_buttons)
			{
				for (var bi:int = 0, blen:int = _buttons.length; bi < blen; bi++)
				{
					_buttons[bi].removeEventListener(ComponentEvent.EVENT_CLICK, onButtonClick);
					_buttons[bi].destroy();
					_buttonArea.removeChild(_buttons[bi]);
					_buttons[bi] = null;
				}
				_buttons = [];
			}
			
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
			
			this.removeChild(_container);
			_container.removeChild(_background);
			_container.removeChild(_contentArea);
			_container.removeChild(_handle);
			_container.removeChild(_buttonArea);
			
			_container = null;
			_background = null;
			_contentArea = null;
			_handle = null;
			_buttonArea = null;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
		
		
	}

}