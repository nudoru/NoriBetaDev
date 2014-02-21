package com.nudoru.utilities
{
	import flash.ui.ContextMenu;
	
	/**
	 * @author Matt Perkins
	 */
	public class ContextMenuUtils
	{
		
		/**
		 * Creates a customized context menu
		 */
		public static function createBlankContextMenu():ContextMenu
		{
			var menu:ContextMenu = new ContextMenu();
			menu.hideBuiltInItems();
			//var item:ContextMenuItem = new ContextMenuItem("Nori");
			//_customContextMnu.customItems.push(item);
			return menu;
		}
		
	}
}
