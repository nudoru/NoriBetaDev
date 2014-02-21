package com.nudoru.components 
{
	import com.nudoru.visual.drawing.*;

	import flash.display.*;
	
	/**
	 * Progress bar
	 * 
	 * Sample:
	 * 
		
	 */
	public class Border extends AbstractVisualComponent implements IAbstractVisualComponent
	{
		protected var _width			:int;
		protected var _height			:int;
		
		protected var _borderStyle		:String;
		protected var _borderSize		:int;
		protected var _colors			:Array;
		
		protected var _borderMC			:MovieClip;
		protected var _borderMCMetrics	:Object;
		
		public static var NONE			:String = "none";
		public static var MOVIECLIP		:String = "movie_clip";
		public static var OUTLINE		:String = "outline";
		public static var OUTLINE_J		:String = "outline_j";
		public static var GRAD_SQUARE	:String = "grad_square";
		public static var GRAD_ROUND	:String = "grad_round";
		
		
		/**
		 * Constructor
		 */
		public function Border():void
		{
			super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			if (data.border is String)
			{
				_width = data.width;
				_height = data.height;
				_borderStyle = data.border;
				_borderSize = data.size;
				_colors = data.colors;
				
				if (!_borderSize) _borderSize = ComponentTheme.borderSize;
				if (!_borderStyle) _borderStyle = ComponentTheme.borderStyle;
				if (!_colors) _colors = ComponentTheme.colors;
			}
			else if(data.border is MovieClip)
			{
				_borderStyle = Border.MOVIECLIP;
				_borderMC = data.border;
				_borderMCMetrics = data.size;
			}
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			if (_borderStyle != Border.MOVIECLIP)
			{
				var halfBorder:int = _borderSize / 2;
				
				if (_borderStyle == Border.GRAD_SQUARE)
				{
					var gb:GradBox = new GradBox(this, 0, 0, _width, _height, false, { bc:_colors[0] } );
				} 
				else if (_borderStyle == Border.GRAD_ROUND)
				{
					var rgb:RoundGradBox = new RoundGradBox(this, 0, 0, _width, _height, false, _borderSize, { bc:_colors[0] } );
				} 
				else if (_borderStyle == Border.OUTLINE)
				{
					this.graphics.lineStyle(_borderSize, _colors[0], 1, true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
					this.graphics.drawRect(halfBorder, halfBorder, _width-_borderSize, _height-_borderSize);
				} 
				else if (_borderStyle == Border.OUTLINE_J)
				{
					this.graphics.lineStyle(1, _colors[0], 1, true);
					this.graphics.drawRect( -halfBorder-1, -halfBorder-1, _width + (_borderSize+1), _height + (_borderSize+1));
					this.graphics.lineStyle(_borderSize, _colors[1], 1, true, "normal", CapsStyle.SQUARE, JointStyle.MITER);
					this.graphics.drawRect(halfBorder, halfBorder, _width-_borderSize, _height-_borderSize);
					this.blendMode = BlendMode.MULTIPLY;
				}
			}
			else
			{
				this.addChild(_borderMC);
			}
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			this.graphics.clear();
			
			if (_borderMC)
			{
				this.removeChild(_borderMC);
				_borderMC = null;
			}
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
		
		
	}

}