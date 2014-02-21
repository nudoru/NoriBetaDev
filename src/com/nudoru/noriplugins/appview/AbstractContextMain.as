package com.nudoru.noriplugins.appview
{
	import flash.display.Sprite;

	/**
	 * Provides base functionality for a context main app file.
	 * Typically the sub class is the document class of a SWF
	 * 
	 * @author Matt Perkins
	 */
	public class AbstractContextMain extends Sprite
	{
		public function AbstractContextMain()
		{
		}
		
		//--------------------------------------------------------------------
		// UTILITY
		
		/**
		 * Called from a app view to determine if the app was loaded by the view or not
		 * The view needs to register fonts loaded from the assets swf file to either this level or the
		 * load the level to ensure that they're available to all swfs/views
		 */
		public function getName():String
		{
			return "Main";
		}
	}
}
