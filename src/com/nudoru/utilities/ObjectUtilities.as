package com.nudoru.utilities
{
	import flash.utils.describeType;
	import flash.utils.ByteArray;
	
	/**
	 * Various functions for working with Objects
	 */
	public class ObjectUtilities
	{
	
		/**
		 * Creates a clone of an object.
		 * Origionally from here: http://www.kirupa.com/forum/showpost.php?p=1897368&postcount=77
		 * 
		 * @param	source	the object to clone
		 * @return 	A copy of the source object
		 */
		public static function clone(source:Object):* {
			var copier:ByteArray = new ByteArray();
			copier.writeObject(source);
			copier.position = 0;
			return(copier.readObject());
		}
		
		// functions below from http://jacksondunstan.com/articles/509#more-509
		
		/**
		*   Count the properties in an object
		*   @param obj Object to count the properties of
		*   @return The number of properties in the specified object. If the
		*           specified object is null, this is 0.
		*   @author Jackson Dunstan
		*/
		public static function numProperties(obj:Object): int
		{
			var count:int = 0;
			for each (var prop:Object in obj)
			{
				count++;
			}
			return count;
		}
		 
		/**
		*   Check if an object has any properties
		*   @param obj Object to check for properties
		*   @return If the specified object has any properties. If the
		*           specified object is null, this is false.
		*   @author Jackson Dunstan
		*/
		public static function hasProperties(obj:Object): Boolean
		{
			for each (var prop:Object in obj)
			{
				return true;
			}
			return false;
		}
		
		/**
		*   Check if the properties of an object are all the same
		*   @param obj Object whose properties should be checked
		*   @param type Type to check the object's properties against
		*   @return If all of the properties of the specified object are of the
		*           specified type
		*   @author Jackson Dunstan
		*/
		public static function isUniformPropertyType(obj:Object, type:Class): Boolean
		{
			for each (var prop:Object in obj)
			{
				if (!(prop is type))
				{
					return false;
				}
			}
			return true;
		}

		/**
		*   Convert the object to an array. Note that the order of the array is
		*   undefined.
		*   @param obj Object to convert
		*   @return An array with all of the properties of the given object or
		*           null if the given object is null
		*   @author Jackson Dunstan
		*/
		public static function toArray(obj:Object): Array
		{
			if (obj == null)
			{
				return null;
			}
			else
			{
				var ret:Array = [];
				for each (var prop:Object in obj)
				{
					ret.push(prop);
				}
				return ret;
			}
		}

		/**
		*   Convert the object to a string of form: PROP: VAL&PROP: VAL where:
		*     PROP is a property
		*     VAL is its corresponding value
		*     & is the specified optional delimiter
		*   @param obj Object to convert
		*   @param delimiter (optional) Delimiter of property/value pairs
		*   @return An string of all property/value pairs delimited by the
		*           given string or null if the input object or delimiter is
		*           null.
		*   @author Jackson Dunstan
		*/
		public static function toString(obj:Object=null, delimiter:String = "\n"): String
		{
			if (obj == null || delimiter == null)
			{
				return "";
			}
			else
			{
				var ret:Array = [];
				for (var s:Object in obj)
				{
					ret.push(s + ": " + obj[s]);
				}
				return ret.join(delimiter);
			}
		}
	
		/**
		*   Get the properties of an arbitrary object
		*   @param obj Object to get the properties of
		*   @return A list of the properties of the given object. This list is
		*           empty if the given object has no properties, is null, or is
		*           undefined.
		*   @author Jackson Dunstan, JacksonDunstan.com
		*/
		public static function getProperties(obj:*): Vector.<String>
		{
			var ret:Vector.<String> = new Vector.<String>();
		 
			// Null and undefined have no properties
			if (obj == null)
			{
				return ret;
			}
		 
			// Get properties from a for-in loop as long as the object isn't an
			// Array or Vector
			var description:XML = describeType(obj);
			if (!(obj is Array))
			{
				var name:String = String(description.attribute("name"));
				if (name.indexOf("__AS3__.vec::") < 0)
				{
					for (var k:String in obj)
					{
						ret.push(k);
					}
				}
			}
		 
			// Add all properties from the describeType XML. This will be empty
			// for plain Objects, but they are covered by the above for-in loop
			var node:XML;
			for each (node in description.elements("accessor"))
			{
				ret.push(node.@name);
			}
			for each (node in description.elements("variable"))
			{
				ret.push(node.@name);
			}
		 
			return ret;
		}
		
		/**
		 * By Jens Struwe <jens@struwe.net>
		 * Collected from Flash Coders list
		 */
		public static function traceProperties(object:Object, depth:uint = 0):void
		{
			for(var prop : String in object)
			{
				trace(prefix(depth), prop, object[prop]);
				if(object[prop] is Object) traceProperties(object[prop], depth + 1);
			}

			function prefix(depth:uint):String
			{
				var prefix:String = "";
				for(var i:uint = 0; i < depth; i++) prefix += "....";
				return prefix;
			}
		}
		
	}

}