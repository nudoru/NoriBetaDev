package screen.model
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	/**
	 * Knowledge Check Choice value object
	 * @author Matt Perkins
	 */
	public class QuestionChoiceModel extends AbstractScreenModel implements IQuestionChoiceModel
	{

		//---------------------------------------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------------------------------------

		protected var _ChoiceMC		:Sprite;
		protected var _MatchMC		:Sprite;
		protected var _OnMatch		:int = -1;
		protected var _Selected		:Boolean = false;
		
		//---------------------------------------------------------------------
		//
		//	GETTER/SETTER
		//
		//---------------------------------------------------------------------
		
		public function get feedback():String { return _xml.feedback; }
		public function get correct():Boolean { return _xml.correct == "true"; }
		
		public function get choiceSprite():Sprite { return _ChoiceMC; }
		public function set choiceSprite(value:Sprite):void 
		{
			_ChoiceMC = value;
		}
		
		public function get selected():Boolean
		{
			return _Selected;
		}

		public function set selected(value:Boolean):void
		{
			_Selected = value;
		}
		
		public function get match():String { return _xml.match; }
		
		public function get matchSprite():Sprite { return _MatchMC; }
		public function set matchSprite(value:Sprite):void 
		{
			_MatchMC = value;
		}
		
		public function get onMatchIndex():int { return _OnMatch; }
		public function set onMatchIndex(value:int):void 
		{
			_OnMatch = value;
		}
		
		public function get hotspotMetrics():Object
		{
			var position:Array = _xml.hotspot.position.split(",");
			var size:Array = _xml.hotspot.size.split(",");
			return {x:int(position[0]), y:int(position[1]), width:int(size[0]), height:int(size[1]) };
		}
		
		//---------------------------------------------------------------------
		//
		//	CONSTRUCTOR
		//
		//---------------------------------------------------------------------
		
		/**
		 * Constructor
		 * @param	data	XML data
		 */
		public function QuestionChoiceModel(data:XML):void
		{
			super(data);
		}
		
		//---------------------------------------------------------------------
		//
		//	MC CHIOCE
		//
		//---------------------------------------------------------------------
		
		/**
		 * Is a choice type correct?
		 */
		public function isChoiceCorrect():Boolean
		{
			if (correct && !selected)return false;
			if (!correct && selected) return false;
			return true;
		}
		
		//---------------------------------------------------------------------
		//
		//	MATCHING
		//
		//---------------------------------------------------------------------
		
		/**
		 * Simple hittest on the choice sprite and the match sprite
		 */
		public function isOnMatch():Boolean {
			var err:Boolean = false;
			try {
				err = choiceSprite.hitTestObject(matchSprite);
			}catch (e:*) { }
			return err;
		}
		
		/**
		 * More accurate test to determine if the choice or mouse cursor is on the match
		 */
		public function isOnMatchPoint(p:Point):Boolean {
			var err:Boolean = false;
			try {
				err = matchSprite.hitTestPoint(p.x, p.y);
			}catch (e:*) { }
			return err;
		}

	}
	
}