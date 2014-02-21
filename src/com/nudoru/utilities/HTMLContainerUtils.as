package com.nudoru.utilities
{
	import flash.external.ExternalInterface;
	
	/**
	 * Utilities for interacting with the HTML page that containts the Flash movie or properties of the Flash movie itself
	 * @author Matt Perkins
	 */
	public class HTMLContainerUtils
	{
		
		public static function callJSFunctionAndReturnResult(functionName:String):*
		{
		    var result:* = "not_availble";
		    if (ExternalInterface.available) {
		        result = ExternalInterface.call(functionName);
		    }
		    return result;
		}
		
		/**
		 * From here
		 * http://active.tutsplus.com/articles/roundups/15-useful-as3-snippets-on-snipplr-com/
		 */
		public static function getHTMLPageURL():String
		{
		    var url:String = "cannot_get_page_url";
		    if (ExternalInterface.available) {
		        return ExternalInterface.call("window.location.href");
		    }
		    return url;
		}
		
		/**
		 * Returns the fist query string match in the URL
		 */
		public static function getQueryStringValue(parameter:String, source:String):String
		{
			var regexp:RegExp = new RegExp("[?&]"+parameter+"(?:=([^&]*))?", "gi");
			var match:Array = source.match(regexp);
			if(match.length)
			{
				return match[0].split("=")[1];
			}
			return "";
		}
		
		/**
		 * Determines if a url begins with https before defaulting to http
		 */
		public static function getURLProtocol(urlstring:String):String
		{
			if(urlstring.indexOf("https://") == 0)
			{
				return "https://";
			} 
			return "http://";
		}
		
		public static function URLEncodeString(inputString:String):String
		{
			var str:String = escape(inputString);
			str = str.replace(/%20/g, "+");
			return str;
		}
		
		/**
		 * Will parse the file name and look for a FlashVar to determine the XML file name
		 */
		/*protected function getXMLFileName(loadernfo:LoaderInfo):String
		{
			var xmlsrc:String = "";
			
			// gets the name of the SWF file
			try {
				var p:Array = loadernfo.url.split("/");
				var f:String = p[p.length-1].split(".")[0];
				xmlsrc = f+".xml";
			} catch (e:*) { }
			
			// gets a flashvars xml file name
			var flashVars:Object = loadernfo.parameters;
			if (flashVars.file) xmlsrc = unescape(flashVars.file);
			
			return xmlsrc.toLowerCase();
		}*/
	}
}
