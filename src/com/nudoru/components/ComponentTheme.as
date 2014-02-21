package com.nudoru.components {
	
	/**
	 * Theme settings fil used by all of the Nudoru* components
	 * Controls default UI settings (where not specified) and look/feel
	 */
	public class ComponentTheme {

		/**
		 * Default values
		 * Each should have a public getter/setter
		 */
		
		/**
		 * Radius of round rects
		 */
		static protected var _radius				:int = 10;
		/**
		 * Width/height of any scrollbar
		 */
		static protected var _scrollBarSize		:int = 14;
		/**
		 * Show up/down buttons on the scroll bar
		 */
		static protected var _ScrollBarArrowButton	:Boolean = true;
		/**
		 * Color of a highlight rect
		 */
		static protected var _HighlightColor		:Number = 0x66ff00;
		/**
		 * On rollover, this is the maximum alpha value
		 */
		static protected var _HighlightMaxAlpha	:Number = .35;
		/**
		 * Disabled components will be tinted 50% this color
		 */
		static protected var _DisabledTintColor	:Number = 0xaaaaaa;
		/**
		 * Color of arrows on scrollbars or other compoents
		 */
		static protected var _ArrowColor			:Number = 0x666666;
		/**
		 * Gutter is the scroll bar or progress bar track
		 */
		static protected var _GutterLineColor		:Number = 0x333333;
		static protected var _GutterFillColor		:Number = 0xcccccc;
		static protected var _GutterShadowColor	:Number = 0x666666;
		/**
		 * Scroll bar handle, button surface
		 */
		static protected var _HandleColor			:Number = 0xcccccc;
		/**
		 * Outline
		 */
		static protected var _OutlineColor			:Number = 0x333333;
		/**
		 * Mask the covers the UI when a modal window is showing
		 */
		static protected var _ModalMaskColor		:Number = 0x333333;
		/**
		 * Create a TLF text field when possible
		 */
		static protected var _preferTLFtext		:Boolean = false;
		/**
		 * Default for all text, text boxes, button text
		 */
		static protected var _fontName				:String = "_sans";
		static protected var _fontSize				:int = 10;
		static protected var _fontColor			:Number = 0x000000;
		/**
		 * Border where applicable
		 */
		static protected var _borderSize			:int = 10;
		static protected var _borderStyle			:String = Border.GRAD_ROUND;
		
		/**
		 * First color should be light, rest should be darker
		 */
		static protected var _colors				:Array = [0xdddddd, 0x006699, 0x009966];
		/**
		 * Look of the elements
		 */
		static protected var _fillStyle			:String = "fill_gradient";
		static protected var _shape				:String = "shape_round_rect";
		static protected var _texture				:Boolean = true;
		
		/**
		 * Contants
		 */
		public static var FILL_SOLID		:String = "fill_solid";
		public static var FILL_GRADIENT		:String = "fill_gradient";
		public static var SHAPE_RECT		:String = "shape_rectangle";
		public static var SHAPE_ROUND_RECT	:String = "shape_round_rect";
		
		/**
		 * Constructor
		 */
		public function ComponentTheme() {}

		
		/**
		 * Getter setters for properties
		 */
		static public function get scrollBarSize():int { return _scrollBarSize; }
		static public function set scrollBarSize(value:int):void 
		{
			_scrollBarSize = value;
		}
		
		static public function get arrowColor():Number { return _ArrowColor; }
		static public function set arrowColor(value:Number):void 
		{
			_ArrowColor = value;
		}
		
		static public function get gutterLineColor():Number { return _GutterLineColor; }
		static public function set gutterLineColor(value:Number):void 
		{
			_GutterLineColor = value;
		}
		
		static public function get gutterFillColor():Number { return _GutterFillColor; }
		static public function set gutterFillColor(value:Number):void 
		{
			_GutterFillColor = value;
		}
		
		static public function get gutterShadowColor():Number { return _GutterShadowColor; }
		static public function set gutterShadowColor(value:Number):void 
		{
			_GutterShadowColor = value;
		}
		
		static public function get handleColor():Number { return _HandleColor; }
		static public function set handleColor(value:Number):void 
		{
			_HandleColor = value;
		}
		
		static public function get radius():int { return _radius; }
		static public function set radius(value:int):void 
		{
			_radius = value;
		}
		
		static public function get fontName():String { return _fontName; }
		static public function set fontName(value:String):void 
		{
			_fontName = value;
		}
		
		static public function get fontSize():int { return _fontSize; }
		static public function set fontSize(value:int):void 
		{
			_fontSize = value;
		}
		
		static public function get fontColor():Number { return _fontColor; }
		static public function set fontColor(value:Number):void 
		{
			_fontColor = value;
		}
		
		static public function get colors():Array { return _colors; }
		static public function set colors(value:Array):void 
		{
			_colors = value;
		}
		
		static public function get borderSize():int { return _borderSize; }
		static public function set borderSize(value:int):void 
		{
			_borderSize = value;
		}
		
		static public function get borderStyle():String { return _borderStyle; }
		static public function set borderStyle(value:String):void 
		{
			_borderStyle = value;
		}
		
		static public function get fillStyle():String { return _fillStyle; }
		static public function set fillStyle(value:String):void 
		{
			_fillStyle = value;
		}
		
		static public function get shape():String { return _shape; }
		static public function set shape(value:String):void 
		{
			_shape = value;
		}

		static public function get texture():Boolean { return _texture; }
		static public function set texture(value:Boolean):void 
		{
			_texture = value;
		}
		
		static public function get highlightMaxAlpha():Number { return _HighlightMaxAlpha; }
		static public function set highlightMaxAlpha(value:Number):void 
		{
			_HighlightMaxAlpha = value;
		}
		
		static public function get highlightColor():Number { return _HighlightColor; }
		static public function set highlightColor(value:Number):void 
		{
			_HighlightColor = value;
		}
		
		static public function get disabledTintColor():Number { return _DisabledTintColor; }
		static public function set disabledTintColor(value:Number):void 
		{
			_DisabledTintColor = value;
		}
		
		static public function get outlineColor():Number { return _OutlineColor; }
		static public function set outlineColor(value:Number):void 
		{
			_OutlineColor = value;
		}
		
		static public function get preferTLFtext():Boolean { return _preferTLFtext; }
		static public function set preferTLFtext(value:Boolean):void 
		{
			_preferTLFtext = value;
		}
		
		static public function get modalMaskColor():Number { return _ModalMaskColor; }
		static public function set modalMaskColor(value:Number):void 
		{
			_ModalMaskColor = value;
		}
		
		static public function get scrollBarArrowButton():Boolean { return _ScrollBarArrowButton; }
		static public function set scrollBarArrowButton(value:Boolean):void 
		{
			_ScrollBarArrowButton = value;
		}
		
	}
}