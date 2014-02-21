package screen.model
{
	import flash.geom.Point;
	import flash.display.Sprite;
	
	public interface IQuestionChoiceModel
	{
		function get feedback():String;
		function get correct():Boolean;
		function get choiceSprite():Sprite;
		function set choiceSprite(value:Sprite):void;
		function get selected():Boolean;
		function set selected(value:Boolean):void;
		function get match():String;
		function get matchSprite():Sprite;
		function set matchSprite(value:Sprite):void;
		function get onMatchIndex():int;
		function set onMatchIndex(value:int):void;
		function get hotspotMetrics():Object;
		function isChoiceCorrect():Boolean;
		function isOnMatch():Boolean;
		function isOnMatchPoint(p:Point):Boolean;
	}
}