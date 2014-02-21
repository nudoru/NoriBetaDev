package com.nudoru.components 
{
	import com.nudoru.visual.BMUtils;
	import com.nudoru.visual.ColorUtils;
	import com.nudoru.visual.drawing.Checkerboard;
	import com.nudoru.visual.drawing.SolidArc;

	import flash.display.BlendMode;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	
	/**
	 * Progress bar
	 * 
	 * Sample:
	 * 
		import com.nudoru.components.NudoruRadialProgressBar;

		var rbar:NudoruRadialProgressBar = new NudoruRadialProgressBar();
		rbar.x = 10;
		rbar.y = 450;
		rbar.initialize({
			radius:25,
			size:15,
			barcolor:0x00cc00, 
			progress:50,
			border:-5
		});
		rbar.render();
		this.addChild(rbar);
		rbar.addPopShadow(0xffffff);
	 */
	public class RadialProgressBar extends AbstractVisualComponent implements IAbstractVisualComponent
	{
		protected var _radius				:int;
		protected var _size					:int;
		protected var _barColor				:Number;
		protected var _progress				:int;
		
		protected var _border				:int;
		
		protected var _segments				:int = 50;
		
		protected var _barFillSprite		:Sprite;
		protected var _barSprite			:Sprite;
		
		public function get progress():int { return _progress; }
		
		public function set progress(value:int):void 
		{
			_progress = value;
			render();
		}
		
		/**
		 * 3.6 since there are 360 degrees in a circle. 100% = 100x3.6 = 360
		 */
		public function get progressDegrees():int 
		{
			return progress * 3.6;
		}
		
		/**
		 * Segments in the arc, Higher is smoother
		 */
		public function get segments():int { return _segments; }
		public function set segments(value:int):void 
		{
			_segments = value;
		}
		
		/**
		 * Constructor
		 */
		public function RadialProgressBar():void
		{
			super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			_radius = data.radius;
			_size = data.size;
			_barColor = data.barcolor;
			_progress = data.progress;
			_border = data.border;
			
			if (!_size) _size = ComponentTheme.scrollBarSize;

			
			if (!_barColor) _barColor = ComponentTheme.colors[0];
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			if (!_barFillSprite)
			{
				_barFillSprite = drawRadialGutter();
				this.addChild(_barFillSprite);
			}
			
			if (_barSprite) 
			{
				this.removeChild(_barSprite);
				_barSprite = null;
			}
			
			if (progressDegrees > 0)
			{
				_barSprite = drawProgressArc();
				this.addChild(_barSprite);
				BMUtils.applyGlowFilter(_barSprite, 0x000000, .5, 5, 1, false);
			}
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}
		
		/**
		 * Update the display
		 */
		override public function update(data:*= null):void
		{
			progress = data.progress;
		}

		/**
		 * Draws the arc with a gradient fill. Same code as the Grad box drawing functions
		 * @return
		 */
		protected function drawProgressArc():Sprite
		{
			var darkColor:Number = _barColor;
			var hls:Object = ColorUtils.RGBtoHLS(darkColor);
			var darkL:Number  = Math.max(hls.l - 0.2,0);
			var lightL:Number  = Math.min(hls.l + 0.3,1);
			var outlineColor:Number = ColorUtils.HLStoRGB(hls.h, darkL, hls.s);
			var lightColor:Number = ColorUtils.HLStoRGB(hls.h, lightL, hls.s);
			
			var arc:Sprite = new Sprite();
			var colors:Array = [darkColor, lightColor];
			var alphas:Array = [1, 1];
			var ratios:Array = [0, 255];
			var matrix:Matrix = new Matrix;
			matrix.createGradientBox(_radius*2, _radius*2, 45);
			//arc.graphics.lineStyle(1, outlineColor);
			arc.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, matrix);
			SolidArc.draw(arc, _radius, _radius, _radius-_size, _radius, -90/360, progressDegrees/360, _segments);
			arc.graphics.endFill();
			
			return arc;
		}
		
		/**
		 * Utility to draw a full circle - used for the gutter
		 * @param	fill	color
		 * @return
		 */
		protected function drawFullCircle(fill:Number = 0xff0000):Sprite
		{
			var circ:Sprite = new Sprite();
			circ.graphics.beginFill(fill, 1);
			SolidArc.draw(circ, _radius, _radius, _radius-(_size+_border), _radius+_border, -90/360, 360/360, _segments);
			circ.graphics.endFill();
			return circ;
		}
		
		/**
		 * Creates a "gutter" area
		 * This code/style is duplicated from the NudoruVisualComponent base class
		 */
		protected function drawRadialGutter():Sprite
		{

			var gutter:Sprite = new Sprite();
			var gutterOutline:Sprite = new Sprite();
			var gutterMask:Sprite = drawFullCircle();
			var gutterTexture:Checkerboard = new Checkerboard(1, 0x000000, 0xffffff, _radius*2, _radius*2);
			var gutterFill:Sprite = drawFullCircle(ComponentTheme.gutterFillColor);

			gutterTexture.x = x;
			gutterTexture.y = y;
			gutterTexture.alpha = .25;
			gutterTexture.blendMode = BlendMode.OVERLAY;
			
			/*gutterOutline.graphics.lineStyle(1, NudoruComponentTheme.gutterLineColor, 1, true);
			if (NudoruComponentTheme.shape == NudoruComponentTheme.SHAPE_ROUND_RECT) gutterOutline.graphics.drawRoundRect(x, y, width, height, radius);
				else gutterOutline.graphics.drawRect(x, y, width, height);*/
				
			gutter.addChild(gutterFill);
			if(ComponentTheme.texture) gutter.addChild(gutterTexture);
			gutter.addChild(gutterMask);
			gutter.addChild(gutterOutline);
			
			gutterFill.mask = gutterMask;
			gutterTexture.mask = gutterMask;

			//gutter.blendMode = BlendMode.MULTIPLY;
			// glow blur is the smaller of width or height
			BMUtils.applyGlowFilter(gutter, ComponentTheme.gutterShadowColor, .75, _size, 1, true);
			return gutter;
		}
		
		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			this.removeChild(_barFillSprite);
			_barFillSprite = null;
			
			this.removeChild(_barSprite);
			_barSprite = null;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
		
		
	}

}