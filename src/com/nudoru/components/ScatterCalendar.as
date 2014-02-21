package com.nudoru.components
{
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.text.TextField;
	
	import com.nudoru.utilities.DateTimeUtils;
	import com.nudoru.utilities.MathUtilities;
	
	import com.greensock.*;
	import com.greensock.easing.*;
	import com.greensock.plugins.*;
	
	/**
	 * Calendar
	 * 
	 * Sample:
	 * 
		var today:Date = new Date();

		calendar.initialize( { year:today.getUTCFullYear(), month:today.getUTCMonth() } );
		calendar.render();
	 */
	public class ScatterCalendar extends AbstractVisualComponent implements IAbstractVisualComponent
	{
		
		protected var _currentMonth			:int;
		protected var _currentYear			:int;
		
		protected var _days					:Array = [];
		
		protected var _firstRender			:Boolean = true;
		
		public function get currentYear():int { return _currentYear; }
		public function get currentMonth():int { return _currentMonth; }
		public function get currentMonthName():String { return DateTimeUtils.getMonth(_currentMonth); }
		public function get currentCalendarData():Array { return DateTimeUtils.getCalendarDayObjects(_currentYear, _currentMonth); }
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Constructor
		
		public function ScatterCalendar():void 
		{
			super();
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Initialization

		override public function initialize(data:*= null):void
		{
			_currentMonth = data.month;
			_currentYear = data.year;
			
			TweenPlugin.activate([BezierThroughPlugin]);
			
			this.nextmonth_btn.addEventListener(MouseEvent.CLICK, onNextMonthClick, false, 0, true);
			this.prevmonth_btn.addEventListener(MouseEvent.CLICK, onPrevMonthClick, false, 0, true);
		}
		
		/*
		o.year = then.getUTCFullYear();
		o.monthIndex = then.getUTCMonth();
		o.monthName = getMonth(then.getUTCMonth());
		o.dayIndex = then.getUTCDay();
		o.dayName = getWeekDay(then.getUTCDay());
		o.date = then.getUTCDate();
		o.dateString = then.toDateString();	//Thu Apr 1 2010
		*/
		override public function render():void
		{
			createDays();

			var xStart:int = 1;
			var x:int = xStart;
			var y:int = 32;
			var xSpace:int = 20;
			var ySpace:int = 15;
			
			month_txt.text = currentMonthName +" " + currentYear;
			
			var daysData:Array = currentCalendarData;

			// offset the first day of the month
			x += xSpace * daysData[0].dayIndex;
			
			var i:int = 0;
			
			for (var len:int = daysData.length; i < len; i++)
			{
				var day = _days[i];

				day.day_txt.text = daysData[i].date;
				
				day.bg_mc.gotoAndStop(1);
				
				if (daysData[i].dayIndex == 0 || daysData[i].dayIndex == 6) day.bg_mc.gotoAndStop(2);
				
				if (!_firstRender)
				{
					TweenMax.killTweensOf(day);
					TweenMax.killDelayedCallsTo(day);
					TweenMax.to(day, 2, { x:x, y:y, rotation:0, bezierThrough:[{x:MathUtilities.rndNum(0, bg_mc.width-day.width), y:MathUtilities.rndNum(0, bg_mc.height-day.height), rotation:MathUtilities.rndNum(-90, 90)}], autoAlpha:1, ease:Expo.easeInOut, motionBlur:true } );
				} else {
					day.x = x;
					day.y = y;
					day.visible = true;
					day.alpha = 1;
				}
				
				x += xSpace;
				
				// if this day was a saturday, wrap back for the sunday except if it's the last day of the month
				if (daysData[i].dayIndex == 6 && i != len-1)
				{
					y += ySpace;
					x = xStart;
				} 
			}
			
			for (; i < 31; i++)
			{
				if (!_firstRender)
				{
					TweenMax.to(_days[i], 1, { x:MathUtilities.rndNum(0, bg_mc.width-_days[i].width), y:MathUtilities.rndNum(0, bg_mc.height-_days[i].height), autoAlpha:0, ease:Expo.easeOut, motionBlur:true } );
				} else {
					_days[i].x = MathUtilities.rndNum(0, bg_mc.width-_days[i].width);
					_days[i].y = MathUtilities.rndNum(0, bg_mc.height-_days[i].height);
					_days[i].visble = false;
					_days[i].alpha = 0;
				}
			}

			if (!_firstRender)
			{
				TweenMax.killTweensOf(bg_mc);
				TweenMax.to(bg_mc, 2, { scaleY:(y + ySpace) * .01, ease:Expo.easeInOut } );	
			} else {
				bg_mc.scaleY = (y+ySpace) * .01;
			}
			
			
			_firstRender = false;
		}
		
		protected function createDays():void
		{
			if (_days.length) return;
			for (var i:int = 0; i < 31; i++)
			{
				var day:CalendarDay = new CalendarDay();
				
				day.x = 0;
				day.y = 0;
				day.visible = false;
				this.addChild(day);
				
				_days.push(day);
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// methods
		
		
		protected function onNextMonthClick(event:Event)
		{
			nextMonth();
		}
		
		protected function onPrevMonthClick(event:Event)
		{
			previousMonth();
		}
		
		protected function nextYear():void
		{
			_currentYear++;
			render();
		}
		
		protected function previousYear():void
		{
			_currentYear--;
			render();
		}
		
		protected function nextMonth():void
		{
			_currentMonth++;
			if (_currentMonth == 12)
			{
				_currentMonth = 0;
				_currentYear++;
			}
			render();
		}
		
		protected function previousMonth():void
		{
			_currentMonth--;
			if (_currentMonth == -1)
			{
				_currentMonth = 11;
				_currentYear--;
			}
			render();
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// destroy

		protected function clearDays():void
		{
			if (!_days.length) return;
			for (var i:int = 0, len:int = _days.length; i < len; i++)
			{
				this.removeChild(_days[i]);
				// remove listeners
				_days[i] = null;
			}
			_days = [];
		}
		
		override public function destroy():void
		{
			clearDays();
			this.nextmonth_btn.removeEventListener(MouseEvent.CLICK, onNextMonthClick);
			this.prevmonth_btn.removeEventListener(MouseEvent.CLICK, onPrevMonthClick);
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
	}
	
}