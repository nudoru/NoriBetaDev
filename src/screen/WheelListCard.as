package screen 
{
	import com.nudoru.components.Button;
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.TextBox;
	import flash.display.Sprite;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author matt perkins
	 */
	public class WheelListCard extends Sprite
	{
		
		public var bg		:Sprite;
		public var text		:TextBox;
		public var close	:Button;
		
		public static const EVENT_CLOSE		:String = "event_close";
		
		public function WheelListCard() 
		{
			super();
		}
	
		public function render(content:String):void
		{
			text = new TextBox();
			text.initialize({
						width:330,
						height:250,
						scroll:true,
						content:content,
						font:"Verdana",
						align:"left",
						size:13,
						leading:7,
						color:0x333333
						});
			text.render();
			
			text.x = 10;
			text.y = 10;
			
			this.addChild(text);
			
			close = new Button();
			close.initialize({
						width:100,
						//height:100,
						label:"Close",
						showface:true,
						facecolor:0x96172e,
						font:"Verdana",
						labelalign:"center",
						size:14,
						color:0xffffff,
						labelshadowcolor:0x671020,
						bordersize:1
						});
			close.render();
			close.x = 134;
			close.y = 275;
			this.addChild(close);
			
			close.addEventListener(ComponentEvent.EVENT_CLICK, onCloseClick, false, 0, true);
		}
		
		private function onCloseClick(event:ComponentEvent):void
		{
			dispatchEvent(new Event(WheelListCard.EVENT_CLOSE));
		}
		
		public function destroy():void
		{
			this.removeChild(text);
			this.removeChild(close);
			text.destroy();
			close.destroy();
			text = undefined;
			close = undefined;
		}
		
	}

}