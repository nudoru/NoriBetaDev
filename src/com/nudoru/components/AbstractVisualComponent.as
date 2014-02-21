package com.nudoru.components 
{
	import com.nudoru.utilities.AccUtilities;
	import com.nudoru.visual.BMUtils;
	import com.nudoru.visual.drawing.*;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;

	import flash.accessibility.*;
	import flash.system.Capabilities;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.MotionBlurPlugin;
	import flash.filters.BlurFilter;
	import flash.filters.BitmapFilterQuality;
	
	/**
	 * Very basic MVC View class.
	 * This class should be subclassed to create more enhanced functionality.
	 */
	public class AbstractVisualComponent extends Sprite implements IAbstractVisualComponent
	{
		
		/**
		 * Enabled toggle
		 */
		protected var _enabled			:Boolean = true;

		public function get enabled():Boolean { return _enabled; }
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
			if (_enabled) showEnabled();
				else showDisabled();
		}
		
		/**
		 * Constructor
		 */
		public function AbstractVisualComponent():void
		{
			super();
			
			TweenPlugin.activate([MotionBlurPlugin]);
		}
		
		/**
		 * Initialize the view
		 */
		public function initialize(data:*=null):void 
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Show enabled state
		 */
		protected function showEnabled():void
		{
			TweenMax.to(this, .25, { alpha:1, colorTransform: { tint:ComponentTheme.disabledTintColor, tintAmount:0 }, ease:Quad.easeOut} );
		}
		
		/**
		 * Show disabled state
		 */
		protected function showDisabled():void
		{
			TweenMax.to(this, .25, { alpha: .5, colorTransform: { tint:ComponentTheme.disabledTintColor, tintAmount:.75 }, ease:Quad.easeOut} );
		}
		
		/**
		 * Draw the view
		 */
		public function render():void
		{
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}

		/**
		 * Get the size of the component
		 * @return Object with width and heigh props
		 */
		public function measure():Object 
		{
			var mObject:Object = new Object();
			mObject.width = this.width;
			mObject.height = this.height;
			return mObject;
		}
		
		/**
		 * Set accessibility properties of an item. 
		 * More information: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/accessibility/AccessibilityProperties.html
		 * @param	mc	Component or sprite to set (if undefined, defaults to component)
		 * @param	name	Accessibility name
		 * @param	desc	Accessibility description
		 * @param	shortcut	Accessibility shortcut key
		 */
		public function setAccessibilityProperties(mc:*, name:String, desc:String="", shortcut:String="", simple:Boolean = false):void
		{
			if (!mc) mc = this;
			/**var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.name = name;
			accessProps.description = desc;
			accessProps.shortcut = shortcut;
			accessProps.forceSimple = simple;
			accessProps.noAutoLabeling = false;
			mc.accessibilityProperties = accessProps;
			if(Capabilities.hasAccessibility) Accessibility.updateProperties();*/
			AccUtilities.setTextProperties(mc, name, desc, shortcut, simple);
		}
			
		/**
		 * Excludes all accessiblity from an item
		 * @param	mc	Component or sprite to set (if undefined, defaults to component)
		 */
		public function excludeFromAccessibility(mc:*):void {
			if (!mc) mc = this;
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.silent = true;
			mc.accessibilityProperties = accessProps;
			mc.tabIndex = -1;
			mc.tabEnabled = false;
		}
		
		/**
		 * Update the display
		 */
		public function update(data:*= null):void
		{
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_UPDATED));
		}
		
		/**
		 * Draw a standardized handle
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	radius
		 * @param	color
		 * @param	varrows
		 * @param	harrows
		 * @return
		 */
		protected function drawHandle(x:int, y:int, width:int, height:int, radius:int = 0, color:Number = undefined, varrows:Boolean = false, harrows:Boolean = false):Sprite
		{
			if (!color) color = ComponentTheme.handleColor;
			var handle:Sprite = new Sprite();
			if (ComponentTheme.shape == ComponentTheme.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(handle, x, y, width, height, false, radius?radius:ComponentTheme.radius, { bc:color } );
				else var shape:GradBox = new GradBox(handle, x, y, width, height, false, { bc:color } );
			
			if (varrows)
			{	
				var uptri:Sprite = drawArrow(width/2, width/4);
				var downtri:Sprite = drawArrow(width/2, width/4);
				downtri.rotation = 180;
				uptri.x = int((width/2) - (uptri.width/2)) + x + 1;
				downtri.x = uptri.x + downtri.width - 1;

				uptri.y = y + 3;
				downtri.y = height - 3;

				handle.addChild(uptri);
				handle.addChild(downtri);
			}
				
			return handle;
		}
		
		/**
		 * Draws a standardized arrow button
		 * @param	width
		 * @param	height
		 * @param	contract
		 * @return
		 */
		protected function drawArrowButton(width:int, height:int, contract:int = 0):Sprite
		{
			var button:Sprite = new Sprite();
			var arrow:Sprite = drawArrow(width - contract, height - contract);
			arrow.x += int(contract / 2);
			arrow.y += int(contract / 2);
			var highlight:Sprite = drawHighlight(0, 0, width, height);
			highlight.name = "hi_mc";
			highlight.alpha = 0;
			
			button.addChild(arrow);
			button.addChild(highlight);
			return button;
		}
		
		/**
		 * Draw a standardized highlight
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	expand
		 * @param	radius
		 * @param	color
		 * @return
		 */
		protected function drawHighlight(x:int, y:int, width:int, height:int, expand:int=0, radius:int=0, color:Number=undefined):Sprite
		{
			if (!color) color = ComponentTheme.highlightColor;
			x -= expand;
			y -= expand;
			width += expand * 2;
			height += expand * 2;
			var hi:Sprite = new Sprite();
			if (ComponentTheme.shape == ComponentTheme.SHAPE_ROUND_RECT) var rshape:RoundGradBox = new RoundGradBox(hi, x, y, width, height, false, radius?radius:ComponentTheme.radius+expand, { bc:color } );
				else var shape:GradBox = new GradBox(hi, x, y, width, height, false, { bc:color } );
			return hi;
		}
		
		/**
		 * Draw a standardized outline
		 * @param	x
		 * @param	y
		 * @param	width
		 * @param	height
		 * @param	expand
		 * @param	radius
		 * @param	color
		 * @return
		 */
		protected function drawOutline(x:int, y:int, width:int, height:int, expand:int=0, color:Number=0x000000, thickness:int=0, radius:int=0):Sprite
		{
			if (!color) color = ComponentTheme.outlineColor;
			x -= expand;
			y -= expand;
			width += expand * 2;
			height += expand * 2;
			var outline:Sprite = new Sprite();
			outline.graphics.lineStyle(thickness, color, 1, true);
			if (ComponentTheme.shape == ComponentTheme.SHAPE_ROUND_RECT) outline.graphics.drawRoundRect(x, y, width, height, radius?radius:ComponentTheme.radius + expand);
				else outline.graphics.drawRect(x, y, width, height);
			return outline;
		}
		
		/**
		 * Creates a "gutter" area - scroll bar track, progress bar background, etd.
		 * Here to standardize the look across components
		 */
		protected function drawGutter(x:int, y:int, width:int, height:int, radius:int=0):Sprite
		{
			var gutter:Sprite = new Sprite();
			var gutterOutline:Sprite = new Sprite();
			var gutterMask:Sprite = new Sprite();
			var gutterTexture:Checkerboard = new Checkerboard(1, 0x000000, 0xffffff, width, height);
			var gutterFill:Sprite = new Sprite();

			if (!radius) radius = ComponentTheme.radius;
			
			gutterMask.graphics.beginFill(0xff0000, 1);
			if (ComponentTheme.shape == ComponentTheme.SHAPE_ROUND_RECT) gutterMask.graphics.drawRoundRect(x, y, width, height, radius);
				else gutterMask.graphics.drawRect(x, y, width, height);
			gutterMask.graphics.endFill();
			
			gutterFill.graphics.beginFill(ComponentTheme.gutterFillColor, 1);
			if (ComponentTheme.shape == ComponentTheme.SHAPE_ROUND_RECT) gutterFill.graphics.drawRoundRect(x, y, width, height, radius);
				else gutterFill.graphics.drawRect(x, y, width, height);
			gutterFill.graphics.endFill();
			
			gutterTexture.x = x;
			gutterTexture.y = y;
			gutterTexture.alpha = .25;
			gutterTexture.blendMode = BlendMode.OVERLAY;
			
			gutterOutline.graphics.lineStyle(1, ComponentTheme.gutterLineColor, 1, true);
			if (ComponentTheme.shape == ComponentTheme.SHAPE_ROUND_RECT) gutterOutline.graphics.drawRoundRect(x, y, width, height, radius);
				else gutterOutline.graphics.drawRect(x, y, width, height);
			
			gutter.addChild(gutterFill);
			if(ComponentTheme.texture) gutter.addChild(gutterTexture);
			gutter.addChild(gutterMask);
			gutter.addChild(gutterOutline);
			
			gutterFill.mask = gutterMask;
			gutterTexture.mask = gutterMask;

			//gutter.blendMode = BlendMode.MULTIPLY;
			// glow blur is the smaller of width or height
			BMUtils.applyGlowFilter(gutter, ComponentTheme.gutterShadowColor, .75, ((height>width?width:height) / 2), 1, true);
			return gutter;
		}
		
		/**
		 * Draw a common arrow shape
		 * @param	width
		 * @param	height
		 * @return
		 */
		protected function drawArrow(width:int, height:int):Sprite
		{
			var tri:Sprite = new Sprite();
			tri.graphics.beginFill(ComponentTheme.arrowColor, .25);
			tri.graphics.lineStyle(1, ComponentTheme.arrowColor, 1);
			tri.graphics.moveTo(width / 2, 0),
			tri.graphics.lineTo(width, height);
			tri.graphics.lineTo(0, height);
			tri.graphics.lineTo(width / 2, 0),
			tri.graphics.endFill();
			
			return tri;
		}
		
		/**
		 * Adds a single pixel shadow on the lower right. 2.0 trendy 1px shadow line
		 * @param	color
		 */
		public function addPopShadow(color:Number = 0xffffff):void
		{
			BMUtils.applyDropShadowFilter(this, 1, 45, color, 1, 0, 1);
		}
		
		/**
		 * Utility funciton to apply a blur to a sprite
		 */
		protected function applyBlurFilter(sprite:*, x:int,y:int):void {
			if (x == 0 && y == 0) return;
			var blur:BlurFilter = new BlurFilter();
			blur.blurX = x;
			blur.blurY = y;
			blur.quality = BitmapFilterQuality.MEDIUM;
			sprite.filters = [blur];
		}
		
		/**
		 * Dispatch events
		 */
		protected function dispatchNudoruEvent(eventType:String,data:String=undefined):void
		{
			var pevent:ComponentEvent = new ComponentEvent(eventType);
			pevent.data = data;
			dispatchEvent(pevent);
		}
		
		/**
		 * Dispatched at various times for each component
		 */
		public function dispatchActivateEvent(data:String=undefined):void
		{
			dispatchNudoruEvent(ComponentEvent.EVENT_ACTIVATE, data);
		}
		
		/**
		 * Dispatched at various times for each component
		 */
		public function dispatchDeactivateEvent(data:String=undefined):void
		{
			dispatchNudoruEvent(ComponentEvent.EVENT_DEACTIVATE, data);
		}
		
		/**
		 * Dispatched at various times for each component
		 */
		public function dispatchClickEvent(data:String=undefined):void
		{
			dispatchNudoruEvent(ComponentEvent.EVENT_CLICK, data);
		}
		
		/**
		 * Helper function to determine if a string value is true or false
		 * @param	s	String to test
		 * @return	If s begins with a "t" then true, else false
		 */
		protected function isBool(s:String):Boolean {
			if (!s) return false;
			if(s.toLowerCase().indexOf("t") == 0) return true;
			return false;
		}
		
		/**
		 * When the component is removed from the stage, run the destroy() function
		 * @param	event
		 */
		protected function onRemovedFromStage(event:Event):void
		{
			this.removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			destroy();
		}
		
		/**
		 * Remove event listeners and remove DisplayObjects from containters
		 */
		public function destroy():void
		{
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
		
	}

}