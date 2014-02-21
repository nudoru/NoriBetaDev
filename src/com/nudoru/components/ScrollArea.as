package com.nudoru.components 
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * Nudoru Scroll Area
	 * version .5 - Only vertical scrolling is supported
	 * 
	 * Reparents a display object, masks it and adds a scroll bar
	 * 
	 * To-do
	 * [ ] fix offsetx
	 * [ ] fix offsety
	 * [ ] add horizontal scrolling
	 * [ ] add update() support
	 * [ ] auto scroll based on mouse position over mask
	 * 
	 * Sample:
	 * 
		sb = new NudoruScrollArea();
		sb.initialize( { barsize:14, content:container, orientation:NudoruScrollArea.VERTICAL, width:200, height:300} );
		this.addChild(sb);
		sb.render();
	 */
	public class ScrollArea extends AbstractVisualComponent implements IAbstractVisualComponent
	{
		
		// Private vars
		protected var _Width				:int;
		protected var _Height				:int;
		// 14 is the optimal size
		protected var _ScrollBarSize		:int;
		protected var _OriginX				:int;
		protected var _OriginY				:int;
		protected var _VBarOffsetX			:int;
		protected var _VBarOffsetY			:int;
		protected var _Orientation			:String;
		protected var _Animate				:Boolean;
		protected var _ScrollObjectMask		:Sprite;
		protected var _ScrollObject			:*;
		protected var _ScrollObjectHolder	:Sprite;
		protected var _VScrollTrack			:Sprite;
		protected var _VScrollThumb			:Sprite;
		protected var _VScrollThumbHi		:Sprite;
		protected var _VScrollUpButton		:Sprite;
		protected var _VScrollDownButton	:Sprite;
		
		protected var _ScrollObjectOrigParent:*;
		protected var _ScrollObjectWidth	:int;
		protected var _ScrollObjectHeight	:int;
		protected var _VScrollThumbHeight	:int;
		protected var _VScrollTrackHeight	:int;
		protected var _VScrollButtonHeight	:int;
		protected var _VRatio				:Number;
		
		// use mouse wheeel to scroll vertically
		protected var _VScrollMouseWheel	:Boolean = true;
		
		// was scrolling applied?
		protected var _VScrollingApplied	:Boolean = false;
		protected var _HScrollingApplied	:Boolean = false;
		
		// colors of the parts
		protected var _ThumbColor			:Number;

		// outline the area of the component
		protected var _ShowBorder			:Boolean = false;
		
		// true if the area is being interacted with to scroll
		protected var _Scrolling			:Boolean = false;
		
		public static var VERTICAL			:String = "vertical";
		public static var HORIZONTAL		:String = "horizontal";
		
		/**
		 * Current vertical position of the scroll object
		 */
		public function get vPosition():Number
		{
			return (_VRatio * _VScrollThumb.y * -1);
		}
		
		/**
		 * Animate the scrolling action
		 */
		public function get animate():Boolean { return _Animate; }
		public function set animate(value:Boolean):void 
		{
			_Animate = value;
		}
		
		/**
		 * Top most scroll position
		 */
		public function get VscrollTop():Number 
		{
			return 0;
		}
		
		/**
		 * Bottom most scroll position
		 */
		public function get VscrollBottom():Number
		{
			return _VScrollTrackHeight- _VBarOffsetY;
		}
		
		/**
		 * Object being scrolled 
		 */
		public function get content():Sprite { return _ScrollObject; }
		
		public function get vScrollMouseWheel():Boolean { return _VScrollMouseWheel; }
		public function set vScrollMouseWheel(value:Boolean):void 
		{
			_VScrollMouseWheel = value;
		}
		
		/**
		 * Constructor
		 */
		public function ScrollArea():void
		{
			super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			_ScrollBarSize = data.barsize;
			_VScrollButtonHeight = _ScrollBarSize;
			_ScrollObject = data.content;
			_Width = data.width;
			_Height = data.height;
			
			_VBarOffsetX = data.offsetx;
			_VBarOffsetY = data.offsety;
			_Orientation = data.orientation;
			
			_ThumbColor = data.thumbcolor;
			
			_OriginX = _ScrollObject.x;
			_OriginY = _ScrollObject.y;
			
			if (!_ScrollObject)
			{
				throw(new Error("Must pass a target"));
				return;
			}
			
			if (!_Width && !_Height)
			{
				throw(new Error("Must pass either a width or a height"));
				return;
			}
			
			if (!_ThumbColor) _ThumbColor = ComponentTheme.handleColor;
			
			// store the object's origional parent
			// wrap in a try/catch just in case
			try {
				_ScrollObjectOrigParent = _ScrollObject.parent;
			} catch(e:*) {}
			
			if (!_ScrollBarSize) _ScrollBarSize = ComponentTheme.scrollBarSize;
			if (!_Width) _Width = _ScrollObject.width;
			if (!_Height) _Height = _ScrollObject.height;
			if (!_VBarOffsetX)_VBarOffsetX = 0;
			if (!_VBarOffsetY) _VBarOffsetY = 0;
			if (!_Orientation) _Orientation = ScrollArea.VERTICAL;

			_ScrollObjectWidth = _ScrollObject.width;
			_ScrollObjectHeight = _ScrollObject.height;

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			this.x = _OriginX;
			this.y = _OriginY;
			
			createContainers();
			
			// only draw the vertical bar if the object overflows
			if (_ScrollObjectHeight > _Height) 
			{
				_VScrollingApplied = true;
				addVScrolling();
			}

			if (_ShowBorder)
			{
				var size:Object = measure();
				this.graphics.lineStyle(1, 0, 1);
				this.graphics.drawRect(0, 0, size.width, size.height);
			}
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		/**
		 * Creates the container sprites
		 */
		protected function createContainers():void
		{
			_ScrollObjectMask = new Sprite();
			_ScrollObjectHolder = new Sprite();
			_VScrollTrack = new Sprite();
			_VScrollThumb = new Sprite();
			_VScrollThumbHi = new Sprite();
			
			_ScrollObjectMask.graphics.beginFill(0xff0000);
			_ScrollObjectMask.graphics.drawRect(0, 0, _Width, _Height);
			_ScrollObjectMask.graphics.endFill();
			
			_ScrollObjectHolder.addChild(_ScrollObject);
			_ScrollObjectHolder.addChild(_ScrollObjectMask);
			_ScrollObject.mask = _ScrollObjectMask;
			_ScrollObject.x = 0;
			_ScrollObject.y = 0;
			
			this.addChild(_ScrollObjectHolder);
			this.addChild(_VScrollTrack);
			this.addChild(_VScrollThumb);
		}

		/**
		 * Add the vertical scroll bar
		 */
		protected function addVScrolling():void
		{
			// calculate the height of the thumb so that it's proportional to the height of the area and the amount of content overflow
			if (ComponentTheme.scrollBarArrowButton)
			{
				_Height -= _VScrollButtonHeight * 2;
				_VBarOffsetY = _VScrollButtonHeight;
				
				_VScrollThumbHeight = _Height * (_Height / _ScrollObjectHeight);
				if (_VScrollThumbHeight < 20) _VScrollThumbHeight = 20;
				_VScrollTrackHeight = _Height - _VScrollThumbHeight;
			} 
			else 
			{
				_VScrollThumbHeight = _Height * (_Height / _ScrollObjectHeight);
				if (_VScrollThumbHeight < 20) _VScrollThumbHeight = 20;
				_VScrollTrackHeight = _Height - _VScrollThumbHeight;
			}
			
			// ratio determins how much to move the object based on how much the thumb moves
			_VRatio = (_ScrollObjectHeight - _VScrollTrackHeight - _VScrollThumbHeight - (_VBarOffsetY * 2)) / _VScrollTrackHeight;
			
			drawVericalBar();

			_VScrollThumb.buttonMode = true;
			_VScrollThumb.mouseChildren = false;
			_VScrollThumb.addEventListener(MouseEvent.ROLL_OVER, onVThumbOver, false, 0, true);
			_VScrollThumb.addEventListener(MouseEvent.ROLL_OUT, onVThumbOut, false, 0, true);
			_VScrollThumb.addEventListener(MouseEvent.MOUSE_DOWN, onVThumbDown, false, 0, true);
			_VScrollTrack.buttonMode = true;
			_VScrollTrack.mouseChildren = false;
			_VScrollTrack.addEventListener(MouseEvent.ROLL_OVER, onVTrackOver, false, 0, true);
			_VScrollTrack.addEventListener(MouseEvent.ROLL_OUT, onVTrackOut, false, 0, true);
			_VScrollTrack.addEventListener(MouseEvent.MOUSE_DOWN, onVTrackDown, false, 0, true);
			
			if (vScrollMouseWheel)
			{
				_ScrollObjectHolder.addEventListener(MouseEvent.ROLL_OVER, onSOHolderOver, false, 0, true);
				_ScrollObjectHolder.addEventListener(MouseEvent.ROLL_OUT,  onSOHolderOut, false, 0, true);
			}
			
			fadeVBars();
		}

		/**
		 * Draw the vertical scroll bar
		 */
		protected function drawVericalBar():void
		{
			var radius:int = _ScrollBarSize;
			_VScrollTrack.addChild(drawGutter(_Width, _VBarOffsetY, _ScrollBarSize, _Height, radius));
			_VScrollThumb.addChild(drawHandle(_Width, _VBarOffsetY, _ScrollBarSize, _VScrollThumbHeight, radius, _ThumbColor, !ComponentTheme.scrollBarArrowButton));
			_VScrollThumbHi.addChild(drawHighlight(_Width, _VBarOffsetY, _ScrollBarSize, _VScrollThumbHeight, 0, radius));
			_VScrollThumb.addChild(_VScrollThumbHi);
			_VScrollThumbHi.alpha = 0;
			
			setAccessibilityProperties(_VScrollThumb, "Scroll bar handle");
			
			if (ComponentTheme.scrollBarArrowButton)
			{
				_VScrollUpButton = drawArrowButton(_ScrollBarSize, _VScrollButtonHeight, 6);
				_VScrollDownButton = drawArrowButton(_ScrollBarSize, _VScrollButtonHeight, 6);
				
				_VScrollUpButton.x = _Width;
				_VScrollUpButton.y = 0;
				
				_VScrollDownButton.rotation = 180;
				_VScrollDownButton.x = _ScrollBarSize + _Width;
				_VScrollDownButton.y = _VScrollTrack.y + _VScrollTrack.height + (_VScrollButtonHeight*2);
				
				_VScrollDownButton.buttonMode = _VScrollUpButton.buttonMode = true;
				_VScrollDownButton.mouseChildren = _VScrollUpButton.mouseChildren = false;
				
				_VScrollUpButton.addEventListener(MouseEvent.ROLL_OVER, onVScrollButtonOver, false, 0, true);
				_VScrollDownButton.addEventListener(MouseEvent.ROLL_OVER, onVScrollButtonOver, false, 0, true);
				_VScrollUpButton.addEventListener(MouseEvent.ROLL_OUT, onVScrollButtonOut, false, 0, true);
				_VScrollDownButton.addEventListener(MouseEvent.ROLL_OUT, onVScrollButtonOut, false, 0, true);
				
				_VScrollUpButton.addEventListener(MouseEvent.CLICK, onVScrollUpButtonClick, false, 0, true);
				_VScrollDownButton.addEventListener(MouseEvent.CLICK, onVScrollDownButtonClick, false, 0, true);
				
				this.addChild(_VScrollUpButton);
				this.addChild(_VScrollDownButton);
				
				setAccessibilityProperties(_VScrollUpButton, "Scroll up button");
				setAccessibilityProperties(_VScrollDownButton, "Scroll down button");
			}
			
			excludeFromAccessibility(_VScrollTrack);
			
			_VScrollThumb.addEventListener(FocusEvent.FOCUS_IN, onVThumbFocusIn, false, 0, true);
			_VScrollThumb.addEventListener(FocusEvent.FOCUS_OUT, onVThumbFocusOut, false, 0, true);
		}
		
		
		
		/**
		 * Mask over, add turn on mouse wheel scrolling
		 * @param	e
		 */
		private function onSOHolderOver(e:MouseEvent):void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScrollWheel, false, 0, true);
		}
		
		/**
		 * Mask over, add turn off mouse wheel scrolling
		 * @param	e
		 */
		private function onSOHolderOut(e:MouseEvent):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onScrollWheel);
		}
		
		/**
		 * Scroll vertically on mouse wheel
		 * @param	e
		 */
		protected function onScrollWheel(e:MouseEvent):void
		{
			if (!_VScrollingApplied) return;
			
			vScrollBy(e.delta*-2);
		}
		
		/**
		 * Scroll by the number of pixels
		 * @param	pixels	Pixels to move the scroll bar (content will update). Will not go above/below max/min allowable values
		 */
		protected function vScrollBy(pixels:int):void
		{
			_VScrollThumb.y += pixels;
			
			if (_VScrollThumb.y < 0) 
			{
				_VScrollThumb.y = 0;
			}
			if (_VScrollThumb.y > _VScrollTrackHeight) 
			{
				_VScrollThumb.y = _VScrollTrackHeight;
			}
			
			updateScrollObjectPosition();
		}
		
		/**
		 * Handles tab focus on the scroll bar
		 * @param	e
		 */
		protected function onVThumbFocusIn(e:FocusEvent):void
		{
			this.addEventListener(KeyboardEvent.KEY_DOWN, onBarKeyPress, false, 0, true);
			this.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange, false, 0, true);
		}
		
		/**
		 * Handles tab focus out on the scroll bar
		 * @param	e
		 */
		protected function onVThumbFocusOut(e:FocusEvent):void
		{
			this.removeEventListener(KeyboardEvent.KEY_DOWN, onBarKeyPress);
			this.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange);
		}
		
		/**
		 * Handles key presss on the bar when it has tab focus
		 * @param	e
		 */
		protected function onBarKeyPress(e:KeyboardEvent):void
		{
			if (_Scrolling || !_enabled) return;
			// up
			if (e.keyCode == 38) vScrollBy(-10);
			// down
			else if (e.keyCode == 40) vScrollBy(10);
		}
		
		/**
		 * Traps the arrow keys, which normally change focus, to allow them to control the scrolling
		 * @param	e
		 */
		protected function onKeyFocusChange(e:FocusEvent):void
		{
			if (e.keyCode == 38 || e.keyCode == 40) e.preventDefault();
		}

		/**
		 * Fades the vbars down to a normal state
		 */
		protected function fadeVBars():void
		{
			TweenMax.to(_VScrollTrack, .75, { alpha:.1, ease:Quad.easeOut } );
			//TweenMax.to(_VScrollThumb, 1, { alpha:.5, ease:Quad.easeOut } );
			TweenMax.to(_VScrollThumbHi, .5, { alpha:0, ease:Quad.easeOut } );
		}
		
		/**
		 * Scrolling buttons over or under the scroll bar
		 * @param	e
		 */
		protected function onVScrollButtonOver(e:Event):void
		{
			if (_Scrolling || !_enabled) return;
			TweenMax.to(e.target.getChildByName("hi_mc"), .25, { alpha:ComponentTheme.highlightMaxAlpha, ease:Quad.easeOut } );
			onVTrackOver(undefined);
		}
		
		/**
		 * Scrolling buttons over or under the scroll bar
		 * @param	e
		 */
		protected function onVScrollButtonOut(e:Event):void
		{
			if (_Scrolling || !_enabled) return;
			TweenMax.to(e.target.getChildByName("hi_mc"), .5, { alpha:0, ease:Quad.easeOut } );
			onVTrackOut(undefined);
		}
		
		/**
		 * scroll up
		 * @param	e
		 */
		protected function onVScrollUpButtonClick(e:Event):void
		{
			vScrollBy(-_VScrollThumbHeight*.75);
		}
		
		/**
		 * scroll down
		 * @param	e
		 */
		protected function onVScrollDownButtonClick(e:Event):void
		{
			vScrollBy(_VScrollThumbHeight*.75);
		}
		
		/**
		 * Handlers for the track events
		 */
		protected function onVTrackOver(event:Event):void
		{
			if (_Scrolling || !_enabled) return;
			TweenMax.killTweensOf(_VScrollTrack);
			TweenMax.killTweensOf(_VScrollThumb);
			TweenMax.to(_VScrollTrack, .25, { alpha:.75, ease:Quad.easeOut } );
			TweenMax.to(_VScrollThumb, .5, { alpha:1, ease:Quad.easeOut } );
		}
		
		/**
		 * Handlers for the track events
		 */
		protected function onVTrackOut(event:Event):void
		{
			if (_Scrolling || !_enabled) return;
			TweenMax.killTweensOf(_VScrollTrack);
			TweenMax.killTweensOf(_VScrollThumb);
			fadeVBars();
		}
		
		/**
		 * Handlers for the track events
		 */
		protected function onVTrackDown(event:Event):void
		{
			if (!_enabled) return;
			
			TweenMax.killTweensOf(_VScrollTrack);
			TweenMax.killTweensOf(_VScrollThumb);
			
			// where on the track was the click
			var clickY:int = event.target.mouseY-_VBarOffsetY;
			// adjust based on click over or under the thumb
			var thumbY:int = clickY < _VScrollThumb.y ? clickY : clickY - _VScrollThumbHeight;
			// make sure it doesn't go off the bottom of the track
			if (thumbY > (VscrollTop + _VScrollTrackHeight)) thumbY = VscrollTop + _VScrollTrackHeight;
			
			_VScrollThumb.y = thumbY;
			
			updateScrollObjectPosition();
			
			fadeVBars();
		}
		
		/**
		 * Handlers for the thumb events
		 */
		protected function onVThumbOver(event:Event):void
		{
			if (_Scrolling || !_enabled) return;
			TweenMax.killTweensOf(_VScrollTrack);
			TweenMax.killTweensOf(_VScrollThumb);
			TweenMax.to(_VScrollTrack, .5, { alpha:.5, ease:Quad.easeOut } );
			TweenMax.to(_VScrollThumb, .25, { alpha:1, ease:Quad.easeOut } );
			TweenMax.to(_VScrollThumbHi, .25, { alpha:ComponentTheme.highlightMaxAlpha, ease:Quad.easeOut } );
			dispatchActivateEvent();
		}
		
		/**
		 * Handlers for the thumb events
		 */
		protected function onVThumbOut(event:Event):void
		{
			if (_Scrolling || !_enabled) return;
			TweenMax.killTweensOf(_VScrollTrack);
			TweenMax.killTweensOf(_VScrollThumb);
			fadeVBars();
			TweenMax.to(_VScrollThumbHi, .5, { alpha:0, ease:Quad.easeOut } );
			dispatchDeactivateEvent();
		}
		
		/**
		 * Handlers for the thumb events
		 */
		protected function onVThumbDown(event:Event):void
		{
			if (!_enabled) return;
			TweenMax.killTweensOf(_VScrollTrack);
			TweenMax.killTweensOf(_VScrollThumb);
			TweenMax.to(_VScrollTrack, .25, { alpha:.75, ease:Quad.easeOut } );
			TweenMax.to(_VScrollThumb, .25, { alpha:1, ease:Quad.easeOut } );
			
			_Scrolling = true;
			_VScrollThumb.startDrag(false, new Rectangle(_VScrollThumb.x, VscrollTop, _VScrollThumb.x, _VScrollTrackHeight));
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onVThumbRelease, false, 0, true);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onVThumbDrag, false, 0, true);
			
			dispatchClickEvent();
		}
		
		/**
		 * Handlers for the thumb events
		 */
		protected function onVThumbRelease(event:Event):void
		{
			if (!_enabled) return;
			_Scrolling = false;
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onVThumbDrag);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onVThumbRelease);
			_VScrollThumb.stopDrag();

			TweenMax.killTweensOf(_VScrollTrack);
			TweenMax.killTweensOf(_VScrollThumb);
			
			fadeVBars();
		}
		
		/**
		 * Update the object's position as the thumb is being dragged
		 * @param	event
		 */
		protected function onVThumbDrag(event:Event):void
		{
			updateScrollObjectPosition();
		}
		
		/**
		 * Animate the object to the new position
		 */
		protected function updateScrollObjectPosition():void
		{
			TweenMax.to(_ScrollObject, .5, { y:vPosition, ease:Back.easeOut } );
			
			var evt:ScrollBarEvent = new ScrollBarEvent(ScrollBarEvent.EVENT_SCROLL);
			evt.position = vPosition;
			dispatchEvent(evt);
		}

		/**
		 * Get the size of the component
		 * @return Object with width and heigh props
		 */
		override public function measure():Object 
		{
			var mObject:Object = new Object();
			//TODO adjust properly for v/h scrolling
			mObject.width = _Width+_ScrollBarSize;
			mObject.height = _Height;
			return mObject;
		}

		// removes all scrolling
		public function removeScrolling():void
		{
			removeVScrolling();
			
			_ScrollObjectHolder.removeChild(_ScrollObject);
			_ScrollObjectHolder.removeChild(_ScrollObjectMask);
			_ScrollObject.mask = null;
			
			this.removeChild(_ScrollObjectHolder);
			
			_ScrollObjectOrigParent.addChild(_ScrollObject);
			_ScrollObject.x = _OriginX;
			_ScrollObject.y = _OriginY;
			
			_ScrollObjectMask = null;
			_ScrollObjectHolder = null;
			_ScrollObjectOrigParent = null;
		}
		
		/**
		 * Remove vertical scroll bar
		 */
		protected function removeVScrolling():void
		{
			if (!_VScrollingApplied) return;
			
			_VScrollThumb.removeEventListener(MouseEvent.ROLL_OVER, onVThumbOver);
			_VScrollThumb.removeEventListener(MouseEvent.ROLL_OUT, onVThumbOut);
			_VScrollThumb.removeEventListener(MouseEvent.MOUSE_DOWN, onVThumbDown);
			_VScrollTrack.removeEventListener(MouseEvent.ROLL_OVER, onVTrackOver);
			_VScrollTrack.removeEventListener(MouseEvent.ROLL_OUT, onVTrackOut);
			_VScrollTrack.removeEventListener(MouseEvent.MOUSE_DOWN, onVTrackDown);
			if (_Scrolling)
			{
				this.stage.removeEventListener(MouseEvent.MOUSE_UP, onVThumbRelease);
				this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onVThumbDrag);
			}
			
			_VScrollThumb.removeEventListener(FocusEvent.FOCUS_IN, onVThumbFocusIn);
			_VScrollThumb.removeEventListener(FocusEvent.FOCUS_OUT, onVThumbFocusOut);
			this.removeEventListener(KeyboardEvent.KEY_DOWN, onBarKeyPress);
			this.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, onKeyFocusChange);
			
			_VScrollThumb.removeChild(_VScrollThumbHi);
			this.removeChild(_VScrollTrack);
			this.removeChild(_VScrollThumb);
			_VScrollTrack = undefined;
			_VScrollThumb = undefined;
			_VScrollThumbHi = undefined;
			
			if (vScrollMouseWheel)
			{
				_ScrollObjectHolder.removeEventListener(MouseEvent.ROLL_OVER, onSOHolderOver);
				_ScrollObjectHolder.removeEventListener(MouseEvent.ROLL_OUT,  onSOHolderOut);
				// will fail if it's been removed from the stage already
				try {
					this.stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onScrollWheel);
				} catch(e:*) {}
			}
			
			if (ComponentTheme.scrollBarArrowButton)
			{
				
				_VScrollUpButton.removeEventListener(MouseEvent.ROLL_OVER, onVScrollButtonOver);
				_VScrollDownButton.removeEventListener(MouseEvent.ROLL_OVER, onVScrollButtonOver);
				_VScrollUpButton.removeEventListener(MouseEvent.ROLL_OUT, onVScrollButtonOut);
				_VScrollDownButton.removeEventListener(MouseEvent.ROLL_OUT, onVScrollButtonOut);
				_VScrollUpButton.removeEventListener(MouseEvent.CLICK, onVScrollUpButtonClick);
				_VScrollDownButton.removeEventListener(MouseEvent.CLICK, onVScrollDownButtonClick);
				
				this.removeChild(_VScrollUpButton);
				this.removeChild(_VScrollDownButton);
				
				_VScrollDownButton = undefined;
				_VScrollUpButton = undefined;
			}
		}
		
		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			removeScrolling();
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
	}

}