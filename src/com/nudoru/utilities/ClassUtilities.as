package com.nudoru.utilities
{
	import flash.display.DisplayObject;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * Various functions for working with Classes
	 * collected from: http://jacksondunstan.com/articles/512
	 */
	public class ClassUtilities
	{

		/**
		*   Get a class by its fully-qualified name
		*   @param className Fully-qualified name of the class
		*   @return The class with the given name or null if none exists
		*   @author Jackson Dunstan
		*/
		public static function getClassByName(className:String): Class
		{
			try
			{
				return Class(getDefinitionByName(className));
			}
			catch (refErr:ReferenceError)
			{
				return null;
			}
			catch (typeErr:TypeError)
			{
				return null;
			}
		 
			return null;
		}

		/**
		*   Get the class of an object
		*   @param obj Object to get the class of
		*   @return The class of the given object or null if the class cannot be
		*           determined
		*   @author Jackson Dunstan
		*/
		public static function getClass(obj:Object): Class
		{
			if (obj == null)
			{
				return null;
			}
			try
			{
				var className:String = getQualifiedClassName(obj);
				var ret:Class = Class(getDefinitionByName(className));
				if (ret == null && obj is DisplayObject)
				{
					ret = getDisplayObjectClass(DisplayObject(obj));
				}
				return ret;
			}
			catch (refErr:ReferenceError)
			{
				return null;
			}
			catch (typeErr:TypeError)
			{
				return null;
			}
		 
			return null;
		}
		 
		/**
		*   Get the class of a display object
		*   @param obj Object to get the class of
		*   @return The class of the given object or null if the class cannot be
		*           determined
		*   @author Jackson Dunstan
		*/
		public static function getDisplayObjectClass(obj:DisplayObject): Class
		{
			try
			{
				return Class(obj.loaderInfo.applicationDomain.getDefinition(getQualifiedClassName(obj)));
			}
			catch (refErr:ReferenceError)
			{
				return null;
			}
			catch (typeErr:TypeError)
			{
				return null;
			}
		 
			return null;
		}

		/**
		*   Create a Function that, when called, instantiates a class
		*   @author Jackson Dunstan
		*   @param c Class to instantiate
		*   @return A function that, when called, instantiates a class with the
		*           arguments passed to said Function or null if the given class
		*           is null.
		*/
		public static function makeConstructorFunction(className:Class): Function
		{
			if (className == null)
			{
				return null;
			}
		 
			/**
			*   The function to call to instantiate the class
			* 	http://jacksondunstan.com/articles/398
			*   @param args Arguments to pass to the constructor. There may be up to
			*               20 arguments.
			*   @return The instantiated instance of the class or null if an instance
			*          couldn't be instantiated. This happens if the given class or
			*          arguments are null, there are more than 20 arguments, or the
			*          constructor of the class throws an exception.
			*/
			return function(...args:Array): Object
			{
				switch (args.length)
				{
					case 0:
						return new className();
						break;
					case 1:
						return new className(args[0]);
						break;
					case 2:
						return new className(args[0], args[1]);
						break;
					case 3:
						return new className(args[0], args[1], args[2]);
						break;
					case 4:
						return new className(args[0], args[1], args[2], args[3]);
						break;
					case 5:
						return new className(args[0], args[1], args[2], args[3], args[4]);
						break;
					case 6:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5]);
						break;
					case 7:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
						break;
					case 8:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);
						break;
					case 9:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8]);
						break;
					case 10:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9]);
						break;
					case 11:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10]);
						break;
					case 12:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11]);
						break;
					case 13:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12]);
						break;
					case 14:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13]);
						break;
					case 15:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14]);
						break;
					case 16:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15]);
						break;
					case 17:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16]);
						break;
					case 18:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17]);
						break;
					case 19:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18]);
						break;
					case 20:
						return new className(args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7], args[8], args[9], args[10], args[11], args[12], args[13], args[14], args[15], args[16], args[17], args[18], args[19]);
						break;
					default:
						return null;
				}
				return null;
			};
		}

	}

}