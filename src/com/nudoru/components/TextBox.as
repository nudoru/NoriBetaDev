package com.nudoru.components 
{
	
	import flash.text.*;
	import com.nudoru.visual.BMUtils;
	
	/**
	 * Text box
	 * 
	 * Sample:
	 * 
		import com.nudoru.components.NudoruTextBox;
		import com.nudoru.components.Border;

		var text:NudoruTextBox = new NudoruTextBox();
		text.initialize({
					width:250,
					height:200,
					scroll:true,
					content:"It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).",
					font:"Verdana",
					align:"center",
					size:24,
					color:0x333333,
					leading:14,
					bold:false,
					italic:true,
					border:Border.GRAD_SQUARE,
					bordersize:10
					});
		text.render();
		text.x = 10;
		text.y = 10;
		this.addChild(text);
	 */
	public class TextBox extends AbstractVisualComponent implements IAbstractVisualComponent
	{
		
		protected var _width					:int;
		protected var _height					:int;
		
		protected var _content					:String;
		protected var _fontName					:String;
		protected var _fontAlign				:String;
		protected var _fontSize					:int;
		protected var _fontColor				:int;
		protected var _fontLeading				:int;
		protected var _fontKerning				:Number;
		protected var _isBold					:Boolean;
		protected var _isItalic					:Boolean;
		protected var _isUnderline				:Boolean;
		protected var _selectable				:Boolean = false;
		protected var _scroll					:Boolean;
		
		protected var _textField				:TextField;
		
		protected var _scrollArea				:ScrollArea;
		
		protected var _border					:Border;
		protected var _borderWidth				:int;
		protected var _borderHeight				:int;
		protected var _borderStyle				:String;
		protected var _borderSize				:int;
		protected var _borderColors				:Array;
		
		public function get content():String { return _content; }
		
		public function get textHeight():int
		{
			// getting the height of the text field give better results than textHeight
			return _textField.height;
		}
		
		public function get textWidth():int
		{
			return _textField.textWidth;
		}
		
		public function get textField():TextField
		{
			return _textField;
		}
		
		/*public function get fontName():String { return _fontName; }
		public function set fontName(value:String):void 
		{
			_fontName = value;
		}
		
		public function get fontAlign():String { return _fontAlign; }
		public function set fontAlign(value:String):void 
		{
			_fontAlign = value;
		}
		
		public function get fontSize():int { return _fontSize; }
		public function set fontSize(value:int):void 
		{
			_fontSize = value;
		}
		
		public function get fontColor():int { return _fontColor; }
		public function set fontColor(value:int):void 
		{
			_fontColor = value;
		}
		
		public function get fontLeading():int { return _fontLeading; }
		public function set fontLeading(value:int):void 
		{
			_fontLeading = value;
		}
		
		public function get isBold():Boolean { return _isBold; }
		public function set isBold(value:Boolean):void 
		{
			_isBold = value;
		}
		
		public function get isItalic():Boolean { return _isItalic; }
		public function set isItalic(value:Boolean):void 
		{
			_isItalic = value;
		}
		
		public function get selectable():Boolean { return _selectable; }
		public function set selectable(value:Boolean):void 
		{
			_selectable = value;
		}
		
		public function get scroll():Boolean { return _scroll; }
		public function set scroll(value:Boolean):void 
		{
			_scroll = value;
		}*/
		
		/**
		 * Constructor
		 */
		public function TextBox():void
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
			
			_content = data.content;
			_fontName = data.font;
			_fontAlign = data.align;
			_fontSize = int(data.size);
			_fontColor = int(data.color);
			_fontLeading = int(data.leading);
			_fontKerning = Number(data.kerning);
			_isBold = isBool(data.bold);
			_isItalic = isBool(data.italic);
			_isUnderline = isBool(data.underline);
			_scroll = isBool(data.scroll);
			
			_borderWidth = _width;
			_borderHeight = _height;
			_borderStyle = data.border;
			_borderSize = data.bordersize;
			_borderColors = data.bordercolors;
			
			if (!_borderSize) _borderSize = 0;
			
			if (_borderStyle && _borderSize)
			{
				_width -= _borderSize * 2;
				_height -= _borderSize * 2;
			}
			
			if (_scroll)
			{
				_width -= ComponentTheme.scrollBarSize;
			}
			
			if (!_fontName) _fontName = ComponentTheme.fontName;
			if (!_fontAlign) _fontAlign = TextFormatAlign.LEFT;
			if (!_fontSize) _fontSize = ComponentTheme.fontSize;
			if (!_fontColor) _fontColor = ComponentTheme.fontColor;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			_textField = new TextField();
			_textField.name = "__nudoru_text_box_txt";
			_textField.width = _width;

			if (_height && !_scroll) 
			{
				_textField.height = _height;
			} 
			else 
			{
				// this will adjust with autosize, just setting since the default is 100
				_textField.height = 1;
				// should probably use constants here, but that would require an if block, TextFieldAutoSize.LEFT;
				if (_fontAlign) _textField.autoSize = _fontAlign;
					else _textField.autoSize = TextFieldAutoSize.LEFT;
			}

			_textField.wordWrap = true;
			_textField.multiline = true;
            _textField.selectable = _selectable;
			if(_fontName != "_sans") _textField.embedFonts = true;
			_textField.antiAliasType = AntiAliasType.ADVANCED;
			
			// PIXEL fit enhances readability for LEFT aligned text
			// SUBPIXEL is best for center/right aligned
			if(_fontAlign == TextFieldAutoSize.LEFT || !_fontAlign) _textField.gridFitType = GridFitType.PIXEL;
				else _textField.gridFitType = GridFitType.SUBPIXEL;
			
            var format:TextFormat = new TextFormat();
            if(_fontName) format.font = _fontName;
			if(_fontAlign) format.align = _fontAlign;
            if(_fontColor) format.color = _fontColor;
            if(_fontSize) format.size = _fontSize;
			if(_fontLeading) format.leading = _fontLeading;
			if(_isBold) format.bold = true;
			if(_isItalic) format.italic = true;
			if(_isUnderline) format.underline = true;

            _textField.defaultTextFormat = format;
			_textField.htmlText = _content;
			_textField.mouseWheelEnabled = false;
			
			// BUG/HACK? Can't get the textfield's height unless I first access it, don't know why flash isn't updating
			if(_textField.height) {}
			
			//Possible fixes for random issues from here: 
			// http://play.blog2t.net/fixing-jumpy-htmltext-links/
			// http://destroytoday.com/blog/2008/08/workaround-001-actionscripts-autosize-bug/
			var tfheight:Number = _textField.height;
			_textField.autoSize = TextFieldAutoSize.NONE;
			_textField.height = tfheight + _textField.getTextFormat().leading + 1;
			
			if (_borderStyle && _borderSize)
			{
				_textField.x = _borderSize;
				_textField.y = _borderSize;
				
				_border = new Border();
				_border.initialize( {border:_borderStyle, size:_borderSize, colors:_borderColors, width:_borderWidth, height:_borderHeight } );
				_border.render();
				this.addChild(_border);
				
			}
			
			this.addChild(_textField);
			
			if (_scroll && _height)
			{
				_scrollArea = new ScrollArea;
				_scrollArea.initialize( {barsize:ComponentTheme.scrollBarSize, content:_textField, orientation:ScrollArea.VERTICAL, width:_width, height:_height} );
				_scrollArea.render();
				this.addChild(_scrollArea);
			}

			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		override public function addPopShadow(color:Number = 0xffffff):void
		{
			BMUtils.applyDropShadowFilter(_textField, 1, 45, color, 1, 0, 1);
			if (_scrollArea) _scrollArea.addPopShadow(color);
		}
		
		
		/**
		 * Get the size of the component
		 * @return Object with width and heigh props
		 */
		override public function measure():Object 
		{
			var mObject:Object = new Object();
			mObject.width = this.width;
			if (_height) 
			{
				if (textHeight > _height) mObject.height = _height;
					else mObject.height = textHeight;
			} else 
			{
				mObject.height = textHeight;
			}
			//mObject.height = this.height;
			return mObject;
		}
		
		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			if (_border)
			{
				this.removeChild(_border);
				_border.destroy();
				_border = null;
			}
			
			if (_scrollArea)
			{
				_scrollArea.destroy();
				this.removeChild(_scrollArea);
				_scrollArea = null;
			}
			
			this.removeChild(_textField);
			_textField = null;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}

	}

}