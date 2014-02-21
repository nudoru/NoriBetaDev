package screen.view
{
	import flash.display.MovieClip;
	
	/**
	 * Class for creating an interactive view object with common properties
	 * @author Matt Perkins
	 */
	public class InteractiveObjectSprite extends MovieClip 
	{
		
		public var index			:int;
		public var selected			:Boolean = false;
		
		public var id				:String;
		public var displayIdx		:int;
		
		public var angle			:Number;
		
		public var origionalXPos	:int;
		public var origionalYPos	:int;
		public var origionalAlpha	:Number;
		public var origionalScale	:Number;
		public var origionalXScale	:Number;
		public var origionalYScale	:Number;
		public var origionalRotation:Number;
		
		public function InteractiveObjectSprite():void 
		{
			super();
		}
		
		public function setOrigionalProps():void {
			origionalXPos = this.x;
			origionalYPos = this.y;
			origionalAlpha = this.alpha;
			origionalScale = this.scaleX;
			origionalXScale = this.scaleX;
			origionalYScale = this.scaleY;
			origionalRotation = this.rotation;
		}
		
	}
	
}