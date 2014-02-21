package com.nudoru.utilities
{

	public class MathUtilities 
	{

		public static function toDegrees(radians:Number):Number
		{
		    return radians * 180/Math.PI;
		}
		 
		public static function toRadians(degrees:Number):Number
		{
		    return degrees * Math.PI / 180;
		}
		
		/**
		 * Generates a random number within the given range.
		 * 
		 * @example <listing version=<3.0">
		 * var myRandomNumber:Number = rndNum(2, 13);<br/>
		 * trace(myRandomNumber); //returns 7 (a random between 2 and 13)
		 * </listing>
		 * @param minVal the minimum number for the range.
		 * @param maxVal the maxiumum number for the range.
		 * @return returns the random number generated.
		 * 
		 * @author Jason Merrill
		 * */
		public static function rndNum(minVal:Number, maxVal:Number):Number
		{
			return minVal + Math.floor(Math.random()*(maxVal+1-minVal));
		}
		
		/**
		 * Creates an array filled with numbers from 0=n
		 */
		public static function createNumArray(max:int):Array
		{
			var array:Array = new Array();
			for(var i:int=0,len:int = max; i<len;i++)
			{
				array.push(i);
			}
			return array;
		}
		
		/**
		 * Generates an array of random numbers from 1 or 0 to max where all numbers through max are used, and no number is zero (if specified). 
		 * Specify true if no zeros are to be included, specify false if zeros are to be included in the resulting array.
		 * @param	max the maximum range for the numbers.
		 * @param	useZero Specify true if no zeros are to be included, specify false if zeros are to be included in the resulting array.
		 * @return an array of random numbers where no number is the same.
		 **/
		public static function rndNumArray(max:int, useZero:Boolean=false):Array
		{
			var array:Array = [];
			for (var i1:int = 0; i1 < max; i1++)
			{
				array.push("");
			}
			var i2:int = 0;
			while (i2 < array.length)
			{
				var rndNum:Number = rndNum(0, max);
				if (!ArrayUtilities.containedInArray(rndNum, array) )
				{
					//if (useZero) rndNum = rndNum-1;
					array[i2] = rndNum;
					i2++;
				}
			}
			if (useZero)
			{
				var arrLen:int = array.length;
				for (var i3:int = 0; i3 < arrLen; i3++)
				{
					array[i3] = array[i3]-1;
				}
			}
			return array;
		}

		/**
		 * Converts a floating point number to a whole percentage.  For example, this would convert .74234 to 74.
		 * @param floatingPoint the floating point number.
		 * @return the whole number percentage.
		 **/
		public static function floatingPointToPercent(floatingPoint:Number):int
		{
			return Math.round(Number(floatingPoint)*100);
		}

	}
}