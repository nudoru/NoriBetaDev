package scientia.model.VOs 
{
	import com.nudoru.nori.mvc.model.VOs.IAbstractVO;
	
	/**
	 * ...
	 * @author Matt Perkins
	 */
	public class ThemeVO implements IAbstractVO 
	{
		
		/**
		 * Scale the UI as the user resizes the browswer window
		 */
		public var scaleView			:Boolean;
		public var assetsSWF			:String;
		public var highLightColor		:Number;
		public var colors				:Array = [];
		public var fonts				:Array = [];
		
		public function ThemeVO() 
		{
			
		}
		
	}

}