package com.nudoru.noriplugins.viewutils
{
	import flash.display.DisplayObjectContainer;
	
	/**
	 * @author Matt Perkins
	 */
	public class ViewUtilities
	{
		
		public static function removeAndDestroyAllViews(container:DisplayObjectContainer):void
		{
			while(container.numChildren > 0)
			{
				var currentChild:* = container.getChildAt(0);
				if(currentChild.numChildren) removeAndDestroyAllViews(currentChild);
				try
				{
					currentChild.destroy();
				} catch(e:*){}
				container.removeChildAt(0);
			}
		}
		
	}
}
