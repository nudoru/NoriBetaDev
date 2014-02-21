package com.nudoru.components 
{
	import com.nudoru.visual.BMUtils;
	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	
	import com.nudoru.visual.drawing.SolidArc;
	
	/**
	 * Shows time as a duration on a clock face
	 * 
	 * Sample:
	 * 
		import com.nudoru.utilities.MathUtilities;

		timer.initialize({hours:10, minutes:0,hcolor:0x006699,mcolor:0x009966});
		timer.render();

		update_btn.addEventListener(MouseEvent.CLICK, onUpdateClick);

		function onUpdateClick(event:Event):void
		{
			timer.update({hours:MathUtilities.rndNum(1,11), minutes:MathUtilities.rndNum(1,60)});
		}
	 */
	public class TimerClock extends AbstractVisualComponent implements IAbstractVisualComponent
	{
		
		protected var _currentHour				:int;
		protected var _currentMinute			:int;
		
		protected var _hArcColor				:Number;
		protected var _mArcColor				:Number;
		
		public function get hArcLayer():MovieClip
		{
			return this.harc_mc;
		}
		
		public function get mArcLayer():MovieClip
		{
			return this.marc_mc;
		}
		
		public function get hourHand():MovieClip
		{
			return this.hourhand_mc;
		}
		
		public function get minuteHand():MovieClip
		{
			return this.minhand_mc;
		}
		
		public function get shadow():MovieClip
		{
			return this.shadow_mc;
		}
		
		public function get glassGlare():MovieClip
		{
			return this.glare_mc;
		}
		
		public function get face():MovieClip
		{
			return this.face_mc;
		}
		
		/**
		 * Constructor
		 */
		public function TimerClock():void
		{
			super();
		}
		
		/**
		 * Initialize the view
		 */
		override public function initialize(data:*=null):void 
		{
			_currentHour = data.hours;
			_currentMinute = data.minutes;
			_hArcColor = data.hcolor;
			_mArcColor = data.mcolor;
			
			if (!_hArcColor) _hArcColor = ComponentTheme.colors[1];
			if (!_mArcColor) _mArcColor = ComponentTheme.colors[2];
			
			BMUtils.applyGlowFilter(hArcLayer, _hArcColor, .5, 5, 1);
			BMUtils.applyGlowFilter(mArcLayer, _mArcColor, .5, 5, 1);
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Draw the view
		 */
		override public function render():void
		{
			var hrRot:Number = _currentHour * 30;
			var minRot:Number = _currentMinute * 6;

			hArcLayer.graphics.clear();
			mArcLayer.graphics.clear();
			
			if (_currentHour)
			{
				TweenMax.to(hourHand, 1.5, { alpha:1, rotation:hrRot, ease:Quad.easeOut});
				hArcLayer.graphics.lineStyle(1, _hArcColor,1);
				hArcLayer.graphics.beginFill(_hArcColor, 0.75);
				SolidArc.draw(hArcLayer,62, 62, 10, 24, -90/360, hrRot/360, 30);
				hArcLayer.graphics.endFill();
				hArcLayer.alpha = 0;
				//hArcLayer.blendMode = BlendMode.HARDLIGHT;
				TweenMax.to(hArcLayer, 2.5, { alpha:1, ease:Quad.easeOut } );
			} else {
				TweenMax.to(hourHand, 1.5, { alpha:.25, rotation:0, ease:Quad.easeOut});
			}
			
			if (_currentMinute)
			{
				TweenMax.to(minuteHand, 1, { alpha:1, rotation:minRot, ease:Quad.easeOut } );
				mArcLayer.graphics.lineStyle(1, _mArcColor,1);
				mArcLayer.graphics.beginFill(_mArcColor, 0.75);
				SolidArc.draw(mArcLayer,62, 62, 26, 40, -90/360, minRot/360, 40);
				mArcLayer.graphics.endFill();
				mArcLayer.alpha = 0;
				//mArcLayer.blendMode = BlendMode.HARDLIGHT;
				TweenMax.to(mArcLayer, 2, { alpha:1, ease:Quad.easeOut } );
			} else {
				TweenMax.to(minuteHand, 1, { alpha:.25, rotation:0, ease:Quad.easeOut } );
			}
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_RENDERED));
		}
		
		/**
		 * Update the display
		 */
		override public function update(data:*= null):void
		{
			_currentHour = data.hours;
			_currentMinute = data.minutes;
			
			render();
		}
	}

}