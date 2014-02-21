package com.nudoru.utilities
{
	
	/**
	 * ...
	 * @author Matt Perkins
	 */
	public class DateTimeUtils
	{
		
		public static var months:Array = ["January","February","March","April","May","June","July","August","September","October","November","December"];
		public static var monthsAbbrev:Array = ["Jan","Feb","March","April","May","June","July","Aug","Sept","Oct","Nov","Dec"];
		public static var daysInMonths:Array = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
		public static var daysInMonthsLeapYear:Array = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
		public static var days:Array = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
		public static var daysAbbrev:Array = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fr", "Sat"];
		public static var daysLetters:Array = ["S", "M", "T", "W", "T", "F", "S"];
		public static const AM	:String = "am";
		public static const PM	:String = "pm";
		
		public static function getMonth(month:int):String
		{
			return months[month];
		}
		
		public static function getMonthAbbrev(month:int):String
		{
			return monthsAbbrev[month];
		}
		
		public static function getWeekDay(day:int):String
		{
			return days[day];
		}
		
		public static function getWeekDayAbbrev(day:int):String
		{
			return daysAbbrev[day];
		}
		
		/**
		 * Returns the day of the week in which the given date occured
		 * @param	day
		 * @param	month
		 * @param	year
		 * @return
		 */
		public static function getDayOfWeek(day:int, month:int, year:int):String
		{
			var date:Date = new Date(year, month, day);
			return getWeekDay(date.getDay());
		}
		
		/**
		 * Is the supplied year a leap year?
		 * From http://www.codenori.com/KB/recipes/Leap_Year_Macros.aspx
		 * 	A year that is divisible by 4 is a leap year. (Y % 4) == 0
		 * 	Exception to rule 1: a year that is divisible by 100 is not a leap year. (Y % 100) != 0
		 * 	Exception to rule 2: a year that is divisible by 400 is a leap year. (Y % 400) == 0
		 * @param	year
		 * @return
		 */
		public static function isLeapYear(year:int):Boolean
		{ 
			//if (year % 4 == 0) return true;
			if ( (year > 0) && !(year % 4) && ( (year % 100) || !(year % 400) ) ) return true;
			return false;
		}

		/**
		 * Returns the number of days in the month
		 * @param	month
		 * @param	year
		 */
		public static function getDaysInMonth(month:int, year:int):int {
			if (month == 1 && isLeapYear(year)) return daysInMonthsLeapYear[month];
			return daysInMonths[month];
		}

		/**
		 * Gets the index of the month 0-11 from the name
		 * @param	month
		 * @return
		 */
		function getMonthIndex(month:String):int {
			for(var i:Number=0; i<12; i++) {
				if(month.toLowerCase() == getMonth(i).toLowerCase()) return i;
			}
			return 0;
		}
		
		/**
		 * Gets a "readable" date string from the SharePoint date string
		 * @param	date	In the format of: 2010-04-29 10:13:00
		 * @return	Month day, Year
		 */
		public static function getPrettyDateFromSPDateString(date:String):String
		{
			var yearPortion:String = date.split(" ")[0];
			return getWeekDay(createDateObjectFromYYYYMMDD(yearPortion).getDay()) +", " + getPrettyDateFromYYYYMMDD(yearPortion);
		}
		
		/**
		 * Converts a date from "2010-04-29" to "May 29, 2010"
		 * @param	date	in format YYYY-MM-DD
		 * @param	delimiter
		 * @return
		 */
		public static function getPrettyDateFromYYYYMMDD(date:String, delimiter:String="-"):String
		{
			var data:Array = date.split(delimiter);
			return getMonth(int(data[1])-1) +" " + String(int(data[2])) +", " + data[0];
		}

		/**
		 * Converts a date from "04-29-2010" to "May 29, 2010"
		 * @param	date	in format YYYY-MM-DD
		 * @param	delimiter
		 * @return
		 */
		public static function getPrettyDateFromMMDDYYYY(date:String, delimiter:String="-"):String
		{
			var data:Array = date.split(delimiter);
			return getMonth(int(data[0])-1) +" " + String(int(data[1])) +", " + data[2];
		}
		
		public static function getYYYYMMDDFromMMDDYYYY(date:String, delimiter:String = "-"):String
		{
			var data:Array = date.split(delimiter);
			return data[2] + "-" + data[0] +"-" + data[1];
		}
		
		/**
		 * Converts a date from "2010-04-29" to a date object
		 * @param	date	in format YYYY-MM-DD
		 * @param	delimiter
		 * @return
		 */
		public static function createDateObjectFromYYYYMMDD(date:String, delimiter:String="-"):Date
		{
			var data:Array = date.split(delimiter);
			return new Date(int(data[0]), int(data[1]) - 1, int(data[2]));
		}
		
		/**
		 * Returns an array of objects with information for every day in a month.
		 * @param	year	The 4 digit year
		 * @param	month	Index of the mon 0 = January, 11 = December
		 * @return
		 */
		public static function getCalendarDayObjects(year:int, month:int):Array
		{
			var days:Array = [];
			var then:Date = new Date(year, month);
			var totalDays:int = getDaysInMonth(month, year);
			for (var i:int = 0, len:int = totalDays; i < len; i++)
			{
				then.setUTCDate(i+1);
				var o:Object = new Object();
				o.year = then.getUTCFullYear();
				o.monthIndex = then.getUTCMonth();
				o.monthName = getMonth(then.getUTCMonth());
				o.dayIndex = then.getUTCDay();
				o.dayName = getWeekDay(then.getUTCDay());
				o.date = then.getUTCDate();
				o.dateString = then.toDateString();	//Thu Apr 1 2010
				days.push(o);
			}
			return days;
		}
		
		
		/**
		 * Converts an hour value in 24 hour format to 12
		 * @param	hour
		 * @return
		 */
		public static function convertTo12Hour(hour:int):int
		{
			if (hour > 12) return hour - 12;
			return hour;
		}
		
		/**
		 * Useful function from Adobe's help docs
		 * @param	num
		 * @return
		 */
		public static function getUSClockTime(hrs:uint, mins:uint):String {
			var modifier:String = "PM";
			var minLabel:String = doubleDigitFormat(mins);
			if(hrs > 12) {
				hrs = hrs-12;
			} else if(hrs == 0) {
				modifier = "AM";
				hrs = 12;
			} else if(hrs < 12) {
				modifier = "AM";
			}
			return (doubleDigitFormat(hrs) + ":" + minLabel + " " + modifier);
		}
		
		/**
		 * Converts minutes to hours and minutes
		 */
		public static function convertMinsToHrsMins(mins:int):Object
		{
			var o:Object = new Object();
			o.hours = int(mins / 60);
			o.minutes = mins % 60;
			return o;
		}
		
		/**
		 * Convert hours and minutes into a string " XX hours and X minutes"
		 * @param	hours
		 * @param	minutes
		 * @return
		 */
		public function getPrettyDurationText(hours:int, minutes:int):String
		{
			var durationText:String = "";
			if (hours) durationText += hours + " hour";
			if (hours > 1) durationText += "s";
			if (hours && minutes) durationText += " and ";
			if (minutes) durationText += minutes + " minute";
			if (minutes > 1) durationText += "s";
			return durationText;
		}
		
		/**
		 * Useful function from Adobe's help docs
		 * @param	num
		 * @return
		 */
		public static function doubleDigitFormat(num:uint):String {
			if(num < 10) {
				return ("0" + num);
			}
			return String(num);
		}
		
	}
	
}