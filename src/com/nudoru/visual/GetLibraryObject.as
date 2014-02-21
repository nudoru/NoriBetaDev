package com.nudoru.visual
{
	import flash.display.DisplayObject;

	public class GetLibraryObject {
		
		public static function linkage(dobj:DisplayObject, name:String):Object {
			var objC:Class = Class(dobj.loaderInfo.applicationDomain.getDefinition(name));
			var obj:Object = Object(new objC());
			return obj;
		}
		
	}
	
}