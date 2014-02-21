package com.nudoru.utilities
{
	
	/**
	 * Deletegate Class
	 * http://krasimirtsonev.com/blog/article/delegation-in-as3
	 * 
	 * Sample:
	 * 
	 * import flash.utils.setTimeout;
	 *  
	 * setTimeout(Delegate.create(func, "param1text", "param2text"), 1000);
	 *  
	 * function func(param1:String, param2:String):void {
	 *     trace("func param1=" + param1 + " param2=" + param2);
	 * }
	 * 
	 */
	public class Delegate
	{
		public static function create(handler:Function, ... args):Function
		{
			return function(... innerArgs):void
			{
				handler.apply(this, innerArgs.concat(args));
			};
		}
	}
}