package com.nudoru.utilities
{
	
	/**
	 * Validation functions
	 */
	public class ValidationUtilities
	{
		/**
		 * Return true if the email address is valid. This regex is from Grant Skinner
		 * More information here: http://www.regular-expressions.info/email.html
		 * @param	value
		 * @return
		 */
		public static function isValidEmail(value:String):Boolean
		{
			return value.search(/[\s]([\w-\.]+)@((?:[\w]+\.)+)([a-zA-Z]{2,4})/) > -1 ? true : false;
		}
		
		/**
		 * Returns true for a date like YYYY-MM-DD
		 * http://www.regular-expressions.info/dates.html
		 * @param	value
		 * @return
		 */
		public static function isValidDateYYYYMMDD(value:String):Boolean
		{
			return value.search(/^(19|20)\d\d[- /.](0[1-9]|1[012])[- /.](0[1-9]|[12][0-9]|3[01])$/) > -1 ? true : false;
		}
		
		/**
		 * Need to code this
		 * http://www.regular-expressions.info/creditcard.html
		 * @param	value
		 * @return
		 */
		/*public static function isValidCCNumber(value:String):Boolean
		{
			return false;
		}*/
	}
	
}