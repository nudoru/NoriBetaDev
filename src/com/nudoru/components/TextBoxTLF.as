package com.nudoru.components 
{
	
	import com.nudoru.components.TextBox;
	import com.nudoru.visual.BMUtils;
	import flash.text.*;
	import flash.text.engine.*;
	import flashx.textLayout.*;
	import flashx.textLayout.elements.*;
	import flashx.textLayout.formats.*;
	import flashx.textLayout.factory.*;
	import flashx.textLayout.compose.*;
	import flashx.textLayout.container.*;
	import flashx.textLayout.conversion.TextConverter;
	import flash.display.Sprite;
	
	/**
	 * TLF Text box
	 * 
	 * Sample:
			var text:NudoruTextBoxTLF = new NudoruTextBoxTLF();
			text.initialize({
				width:250,
				height:200,
				scroll:true,
				content:"It is a long <a href='#' target='_blank'>established</a> fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).",
				font:"Verdana",
				align:"left",
				size:14,
				color:0x000000,
				leading:30,
				bold:false,
				italic:false,
				border:Border.GRAD_SQUARE,
				bordersize:10
			});
			// set TLF specific options here
			text.render();
			text.x = 10;
			text.y = 10;
			this.addChild(text);
	 */
	public class TextBoxTLF extends TextBox implements IAbstractVisualComponent
	{

		protected var _textFlow			:TextFlow;
		protected var _textFormat		:TextLayoutFormat;
		protected var _textContainer	:ContainerController;
		protected var _container		:Sprite;
		protected var _containerbg		:Sprite;
		protected var _containertext	:Sprite;
		
		// TLF Specific props
		// columns do not work with scrolling
		protected var _textColumns		:int = 1;
		protected var _textColumnGap	:int = 10;
		
		//http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flashx/textLayout/formats/TLFTypographicCase.html
		protected var _textTypeCase		:String = flashx.textLayout.formats.TLFTypographicCase.DEFAULT;
		
		protected var _paraStartIndent	:* = flashx.textLayout.formats.FormatValue.INHERIT;
		protected var _paraSpaceAfter	:* = flashx.textLayout.formats.FormatValue.INHERIT;
		protected var _textIndent		:* = flashx.textLayout.formats.FormatValue.INHERIT;
		
		override public function get textHeight():int
		{
			// getting the height of the text field give better results than textHeight
			return _containertext.height;
		}
		
		override public function get textWidth():int
		{
			return _containertext.width;
		}
		
		override public function get textField():TextField
		{
			return undefined;
		}
		
		public function get textHostFormat():TextLayoutFormat
		{
			return _textFlow.hostFormat as TextLayoutFormat;
		}
		
		public function get textContainer():ContainerController { return _textContainer; }
		
		public function get textFlow():TextFlow { return _textFlow; }
		
		/**
		 * How to change the format:
		 * 
		 * var _textFormat:TextLayoutFormat = text.textHostFormat;
		 * 	_textFormat.color = 0xff0000;
		 * 	text.textFormat = _textFormat;
		 */
		
		public function get textFormat():TextLayoutFormat { return _textFormat; }
		
		public function set textFormat(tf:TextLayoutFormat):void
		{ 
			_textFormat = tf;
			_textFlow.format = _textFormat;
			_textFlow.flowComposer.updateAllControllers();
		}
		
		public function get columns():int { return _textColumns; }
		public function set columns(value:int):void 
		{
			_textColumns = value;
		}
		
		public function get columnGap():int { return _textColumnGap; }
		public function set columnGap(value:int):void 
		{
			_textColumnGap = value;
		}
		
		public function get typeCase():String { return _textTypeCase; }
		public function set typeCase(value:String):void 
		{
			_textTypeCase = value;
		}
		
		public function get paraStartIndent():* { return _paraStartIndent; }
		public function set paraStartIndent(value:*):void 
		{
			_paraStartIndent = value;
		}
		
		public function get paraSpaceAfter():* { return _paraSpaceAfter; }
		public function set paraSpaceAfter(value:*):void 
		{
			_paraSpaceAfter = value;
		}
		
		public function get textIndent():* { return _textIndent; }
		
		public function set textIndent(value:*):void 
		{
			_textIndent = value;
		}
		
		public function TextBoxTLF():void
		{
			super();
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			//http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flashx/textLayout/formats/TextLayoutFormat.html
			_textFormat = new TextLayoutFormat();
			_textFormat.fontSize = _fontSize;
			_textFormat.fontFamily = _fontName;
			_textFormat.color = _fontColor;
			_textFormat.textAlign = _fontAlign;
			if(_fontLeading) _textFormat.lineHeight = _fontLeading;
			_textFormat.kerning = flash.text.engine.Kerning.ON;
			_textFormat.trackingRight = _fontKerning;
			
			if (_isBold) _textFormat.fontWeight = flash.text.engine.FontWeight.BOLD;
			if (_isItalic) _textFormat.fontStyle = flash.text.engine.FontPosture.ITALIC;
			if (_isUnderline) _textFormat.textDecoration = flashx.textLayout.formats.TextDecoration.UNDERLINE;
			
			_textFormat.paragraphSpaceAfter = _paraSpaceAfter;
			_textFormat.paragraphStartIndent = _paraStartIndent;
			_textFormat.textIndent = _textIndent;
			
			_textFormat.columnCount = _textColumns;
			_textFormat.columnGap = _textColumnGap;
			//_textFormat.fontLookup = flash.text.engine.FontLookup.EMBEDDED_CFF;
			_textFormat.renderingMode = flash.text.engine.RenderingMode.CFF;
			_textFormat.typographicCase = _textTypeCase;
			
			_textFormat.whiteSpaceCollapse = flashx.textLayout.formats.WhiteSpaceCollapse.PRESERVE;
			
			_textFlow = TextConverter.importToFlow(_content, TextConverter.TEXT_FIELD_HTML_FORMAT);
			_textFlow.hostFormat = _textFormat;
			
			_container = new Sprite();
			_container.x = _borderSize;
			_container.y = _borderSize;
			
			_containerbg = new Sprite();
			_containertext = new Sprite();
			
			_container.addChild(_containerbg);
			_container.addChild(_containertext);
			
			// the first parameter, this, must point to a DisplayObjectContainer
			// the last two parameters set the initial size of the container in pixels
			_textContainer = new ContainerController(_containertext, _width, (_height && !_scroll ? _height : undefined));
			
			//associate it with the flowComposer property
			_textFlow.flowComposer.addController(_textContainer);
			
			// fourth, update the display list
			_textFlow.flowComposer.updateAllControllers();

			if (_borderStyle && _borderSize)
			{
				_border = new Border();
				_border.initialize( {border:_borderStyle, size:_borderSize, colors:_borderColors, width:_borderWidth, height:_borderHeight } );
				_border.render();
				this.addChild(_border);
			}
			
			this.addChild(_container);
			
			if (_scroll && _height)
			{
				_scrollArea = new ScrollArea;
				_scrollArea.initialize( {barsize:ComponentTheme.scrollBarSize, content:_container, orientation:ScrollArea.VERTICAL, width:_width, height:_height} );
				_scrollArea.render();
				this.addChild(_scrollArea);
				
				// give it a background to allow a better "mouseover" for the mousewheel scrolling
				_containerbg.graphics.beginFill(0xff0000, 0);
				_containerbg.graphics.drawRect(0, 0, _width, _containertext.height);
				_containerbg.graphics.endFill();
			}

		}

		override public function addPopShadow(color:Number = 0xffffff):void
		{
			BMUtils.applyDropShadowFilter(this, 1, 45, color, 1, 0, 1);
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
			return mObject;
		}
		
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
			
			_container.removeChild(_containerbg);
			_container.removeChild(_containertext);
			this.removeChild(_container);
			
			_textContainer = undefined;
			_textFormat = undefined;
			_textFlow = undefined;
			
			_containerbg = undefined;
			_containertext = undefined;
			_container = undefined;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
		
	}
	
}