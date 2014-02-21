package com.nudoru.components 
{
	import flash.display.Sprite;
	
	/**
	 * Progress bar
	 * 
	 * Sample:
	 * 
		import com.nudoru.components.NudoruProgressBar;

		var b:NudoruProgressBar = new NudoruProgressBar();
		b.x = 100;
		b.y = 100;
		b.initialize({width:200, height:14, barcolor:0x00cc00, progress:50,border:0});
		b.render();
		this.addChild(b);
	 */
	public class LinearProgressBar extends AbstractVisualComponent implements IAbstractVisualComponent
	{
		protected var _barHeight			:int;
		protected var _barWidth				:int;
		protected var _pBarHeight			:int;
		protected var _pBarWidth			:int;
		protected var _barColor				:Number;
		protected var _progress				:int;
		
		protected var _mulitplier			:Number;
		
		protected var _border				:int;
		
		protected var _barFillSprite		:Sprite;
		protected var _barSprite			:Sprite;
		
		public function get progress():int { return _progress; }
		
		public function set progress(value:int):void 
		{
			_progress = value;
			render();
		}
		
		public function get progressWidth():int 
		{
			return progress * _mulitplier;
		}
		
		/**
		 * Constructor
		 */
		public function LinearProgressBar():void
		{
			super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			_barHeight = data.height;
			_barWidth = data.width;
			_barColor = data.barcolor;
			_progress = data.progress;
			_border = data.border;
			
			if (!_barHeight) _barHeight = ComponentTheme.scrollBarSize;
			
			_pBarHeight = _barHeight - (_border * 2);
			_pBarWidth = _barWidth - (_border * 2);
			
			_mulitplier = _pBarWidth / 100;
			
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
				_barFillSprite = drawGutter(0, 0, _barWidth, _barHeight, _barHeight);
				_barFillSprite.alpha = .75;
				this.addChild(_barFillSprite);
			}
			
			if (_barSprite) 
			{
				this.removeChild(_barSprite);
				_barSprite = null;
			}
			
			if (progressWidth > 0)
			{
				/*_barSprite = new Sprite();
				_barSprite.x = _border;
				_barSprite.y = _border;
				var b:RoundGradBox = new RoundGradBox(_barSprite, 0, 0, progressWidth, _pBarHeight, false, _pBarHeight, { bc:_barColor } );
				this.addChild(_barSprite);*/
				_barSprite = drawHandle(_border, _border, progressWidth, _pBarHeight, _pBarHeight, _barColor);
				this.addChild(_barSprite);
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