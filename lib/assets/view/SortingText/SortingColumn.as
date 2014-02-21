package assets.view.SortingText
{
	import assets.view.ChoiceSprite;
	
	/**
	 * @author Matt Perkins
	 */
	public class SortingColumn extends ChoiceSprite
	{
		
		public var numTargetsCreatedInColumn:int;
		public var choicesOnColumn:Array=[];
		public var targetsOnColumn:Array=[];
		
		public function SortingColumn():void
		{
			super();
		}
		
	}
}
