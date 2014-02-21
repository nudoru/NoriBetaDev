package com.nudoru.utilities
{
	
	/**
	 * Various functions for working with Array
	 * 
	 * @author Jason Merrill
	 * @author Matt Perkins
	 */
	
	public class ArrayUtilities
	{
	
		/**
		 * Returns the index of value in the array
		 * @param	value	Value to test for in the array
		 * @param	array	Array to look in
		 * @return
		 */
		public static function getArrayIndexOfValue(value:*, array:Array):int
		{
			for (var i:int = 0, len:int = array.length; i < len; i++)
			{
				if (array[i] == value) return i;
			}
			return -1;
		}
	
		/**
		 * Determines if a value is contained within the supplied array.
		 * 
		 * @param value A value of any type to searched for in the array.
		 * @param array The Array to search within.
		 * @return returns true or false if the value was found in the array.
		 **/
		public static function containedInArray(value:*, array:Array):Boolean
		{
			var found:Boolean = false;
			for each (var item:* in array)
			{
				if (value == item)
				{
					found = true;
				}
			}
			return found;
		}
		
		/**
		 * Adds a value to an array only if it does not already exist
		 * @param	$a	Array to add value to
		 * @param	$v	Value to add
		 * @return	True if the value already exists in the array. False if not.
		 */
		public static function addUniqueValue($a:Array, $v:*):Boolean {
			var err:Boolean = containedInArray($v, $a);
			if (!err) $a.push($v);
			return err;
		}
	
		/**
		 * Randomize the contents of an array using the Fisher-Yates algorythm
		 * By Kenneth Kawamoto kennethkawamoto@gmail.com
		 * http://www.materiaprima.co.uk/
		 * Details: http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
		 * @param	arr
		 */
		public static function fisherYatesShuffle(arr:Array):void {
			var i:uint = arr.length;
			while(--i){
				var j:uint = Math.floor(Math.random()*(i + 1));
				var tmpI:Object = arr[i];
				var tmpJ:Object = arr[j];
				arr[i] = tmpJ;
				arr[j] = tmpI;
			}
		}

		/**
		 * Deletes a value(first found occurence) from an array or vector and returns it
		 * TODO should it delete all occurencs?
		 * 
		 * @param array	The array or vector to operate on
		 * @param value	The value to find and delete
		 */
		public static function deleteValueInArray(value:*, array:*):*
		{
			for(var i:int=0,len:int=array.length; i<len; i++)
			{
				if(array[i] == value)
				{
					array = array.splice(i,1);
					return array;
				}
			}
			return array;
		}
		
	}

}