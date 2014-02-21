package screen.controller
{
	import com.nudoru.lms.scorm.InteractionObject;
	import flash.events.IEventDispatcher;
	import com.nudoru.components.IWindowManager;
	
	/**
	 * Data type for a view class
	 */
	public interface IAbstractScreen extends IEventDispatcher
	{
		function set windowManager(value:IWindowManager):void;
		function get screenWidth():int;
		function get screenHeight():int;
		function get screenBorder():int;

		function initialize(data:*=null):void;
		function render():void;
		function setScreenStatusTo(status:int, intObject:InteractionObject = undefined):void;
		function destroy():void;
	}
}