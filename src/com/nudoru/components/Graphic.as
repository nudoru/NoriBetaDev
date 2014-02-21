package com.nudoru.components 
{
	import com.greensock.easing.*;
	import com.greensock.TweenMax;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	/**
	 * Graphic
	 * 
	 * Sample:
	var graphic:NudoruGraphic = new NudoruGraphic();
	graphic.initialize({
					   url:"assets/testimage.jpg", 
					   width:250, 
					   height:250, 
					   border:Border.OUTLINE_J, 
					   bordersize:10, 
					   bordercolors:[0xcccccc, 0x00ff00]
					   //border: new PolaroidFrame(),
					   //bordermetrics:{xoffs:20,yoffs:18,width:308,height:322}
					   });
	graphic.render();
	graphic.x = 300;
	graphic.y = 10;
	addChild(graphic);
	 */
	public class Graphic extends AbstractVisualComponent implements IAbstractVisualComponent
	{
		protected var _url				:String;
		protected var _imageLoader		:ImageLoader;
		
		protected var _progressBar		:LinearProgressBar;
		
		protected var _containerSprite	:Sprite;
		protected var _graphicSprite	:Sprite;
		
		protected var _width			:int;
		protected var _height			:int;

		protected var _border			:Border;
		protected var _borderWidth		:int;
		protected var _borderHeight		:int;
		protected var _borderStyle		:String;
		protected var _borderMC			:MovieClip;
		protected var _borderMCMetrics	:Object;
		protected var _borderSize		:int;
		protected var _borderColors		:Array;
		
		protected var _animate			:Boolean = true;
		
		public function get animate():Boolean { return _animate; }
		public function set animate(value:Boolean):void 
		{
			_animate = value;
		}
		
		public function get url():String { return _url; }
		
		/**
		 * Constructor
		 */
		public function Graphic():void
		{
			super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			_url = data.url;
			_width = data.width;
			_height = data.height;
			
			if (!_width) _width = 100;
			if (!_height) _height = 100;
			
			if (data.border is String)
			{
				_borderStyle = data.border;
				_borderSize = data.bordersize;
				
				if (_borderStyle && !_borderSize) _borderSize = ComponentTheme.borderSize;
				if (_borderSize && !_borderStyle) _borderStyle = ComponentTheme.borderStyle;
				
				_borderColors = data.bordercolors;
			}
			
			if (data.border is MovieClip)
			{
				_borderStyle = Border.MOVIECLIP;
				_borderMC = data.border;
				_borderMCMetrics = data.bordermetrics;
			}

			_containerSprite = new Sprite();
			_graphicSprite = new Sprite();
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			this.addChild(_containerSprite);
			
			_progressBar = new LinearProgressBar();
			_progressBar.x = int((_width/2)-(50));
			_progressBar.y = int((_height/2)-(4));
			_progressBar.initialize({width:100, height:8, barcolor:0x666666, progress:0, border:2});
			_progressBar.render();
			this.addChild(_progressBar);
			
			_progressBar.alpha = 0;
			TweenMax.to(_progressBar, .25, { alpha:1, ease:Quad.easeOut } );
			
			// give the image a size to measure while it loads
			this.graphics.beginFill(0xff0000,0);
			this.graphics.drawRect(0,0,_width,_height);
			this.graphics.endFill();
			
			_imageLoader = new ImageLoader();
			_imageLoader.initialize({url:_url});
			_imageLoader.addEventListener(ComponentEvent.EVENT_PROGRESS, onImageProgress, false, 0, true);
			_imageLoader.addEventListener(ComponentEvent.EVENT_LOADED, onImageLoaded, false, 0, true);
			_imageLoader.addEventListener(ComponentEvent.EVENT_IOERROR, onImageError, false, 0, true);
			_imageLoader.load();
		}

		protected function onImageProgress(event:ComponentEvent):void
		{
			_progressBar.progress = int(event.data);
			
			var pevent:ComponentEvent = new ComponentEvent(ComponentEvent.EVENT_PROGRESS);
			pevent.data = event.data;
			dispatchEvent(pevent);
		}

		protected function onImageLoaded(event:Event):void
		{
			renderImage();
		}

		protected function onImageError(event:Event):void
		{
			trace("NudoruGraphic - error - "+event.type);
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_IOERROR));
		}
		
		protected function renderImage():void
		{
			// clear the temporary sizing rect
			this.graphics.clear();

			_graphicSprite.addChild(_imageLoader.content);
			
			// Update the width/height based on the loaded image
			_width = _graphicSprite.width;
			_height = _graphicSprite.height;
			
			// outline borders should overlap the image
			if (_borderStyle.indexOf("outline") != 0)
			{
				_borderWidth = _width + (_borderSize * 2);
				_borderHeight = _height + (_borderSize * 2);
			} 
			else 
			{
				_borderWidth = _width;
				_borderHeight = _height;
			}
			
			// && _borderSize
			if (_borderStyle)
			{
				// a dynamically drawn border
				if (_borderStyle != Border.MOVIECLIP)
				{
					// outline borders should overlap the image
					if (_borderStyle.indexOf("outline") != 0)
					{
						_graphicSprite.x = _borderSize;
						_graphicSprite.y = _borderSize;
					}
				
					_border = new Border();
					_border.initialize( {border:_borderStyle, size:_borderSize, colors:_borderColors, width:_borderWidth, height:_borderHeight } );
					_border.render();
					_containerSprite.addChild(_border);
				} 
				// a border from a passed movie clip
				else if (_borderStyle == Border.MOVIECLIP)
				{
					_graphicSprite.x = _borderMCMetrics.xoffs;
					_graphicSprite.y = _borderMCMetrics.yoffs;
					_border = new Border();
					_border.initialize( {border:_borderMC, size:_borderMCMetrics} );
					_border.render();
					_containerSprite.addChild(_border);
				}
			}
			
			_containerSprite.addChild(_graphicSprite);
			
			// put the border on top of the graphic
			if(_borderStyle.indexOf("outline")==0 || _borderStyle == Border.MOVIECLIP) _containerSprite.addChild(_border);
			
			TweenMax.to(_progressBar, .25, { autoAlpha:0, ease:Quad.easeOut, onComplete:removeProgressBar } );
			
			if (_animate)
			{
				_containerSprite.alpha = 0;
				applyBlurFilter(_containerSprite, 10, 10);
				TweenMax.to(_containerSprite, 0, { colorTransform: { exposure:2 }} );
				TweenMax.to(_containerSprite,.75,{alpha:1, blurFilter: { blurX:0, blurY:0 }, colorTransform: { exposure:1 }, ease:Expo.easeOut}); 
			}
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}
		
		protected function removeProgressBar():void
		{
			if (!_progressBar) return;
			
			_progressBar.destroy();
			this.removeChild(_progressBar);
			_progressBar = null;
		}

		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		override public function destroy():void
		{
			removeProgressBar();
			
			try {
				_imageLoader.destroy();
				_imageLoader = null;
			} catch (e:*) { }
			
			if (_border)
			{
				_containerSprite.removeChild(_border);
				_border.destroy();
				_border = null;
			}
			
			_borderMC = null;
			
			_containerSprite.removeChild(_graphicSprite);
			this.removeChild(_containerSprite);
			
			_containerSprite = null;
			_border = null;
			_graphicSprite = null;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}

	}

}