package com.nudoru.utilities
{
	
	import flash.accessibility.*;
	import flash.system.Capabilities;
	
	/**
	 * Accessibility Utilities
	 * @author Matt Perkins
	 */
	public class AccUtilities
	{
		private static var _tabCounter:int = 10;
		
		static public function get tabCounter():int
		{
			return _tabCounter;
		}
		
		static public function set tabCounter(value:int):void
		{
			_tabCounter = value;
		}
		
		/**
		 * Set accessibility properties of an item. 
		 * More information: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/accessibility/AccessibilityProperties.html
		 * @param	mc	Component or sprite to set (if undefined, defaults to component)
		 * @param	name	Accessibility name
		 * @param	desc	Accessibility description
		 * @param	shortcut	Accessibility shortcut key
		 */
		public static function setTextProperties(mc:*, name:String, desc:String="", shortcut:String="", simple:Boolean = true):void
		{
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.name = name;
			accessProps.description = desc;
			accessProps.shortcut = shortcut;
			accessProps.forceSimple = simple;
			accessProps.noAutoLabeling = false;
			mc.accessibilityProperties = accessProps;
			if(Capabilities.hasAccessibility) Accessibility.updateProperties();
		}
		 
		public static function setProperties(mc:*, name:String, desc:String="", shortcut:String="", simple:Boolean = true):void
		{
			setTextProperties(mc, name, desc, shortcut, simple);
			mc.tabIndex = tabCounter++;
			//mc.tabEnabled = true;
		}
	
		/**
		 * Excludes all accessiblity from an item
		 * @param	mc	Component or sprite to set (if undefined, defaults to component)
		 */
		public static function exclude(mc:*):void {
			var accessProps:AccessibilityProperties = new AccessibilityProperties();
			accessProps.silent = true;
			mc.accessibilityProperties = accessProps;
			mc.tabIndex = -1;
			mc.tabEnabled = false;
		}

	}
	
}