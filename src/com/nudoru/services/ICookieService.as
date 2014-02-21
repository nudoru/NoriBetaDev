package com.nudoru.services
{
	public interface ICookieService
	{
		function save(id:String, d:String):Boolean;
		function clear(id:String):Boolean;
		function load(id:String):String;
	}
}