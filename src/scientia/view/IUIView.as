package scientia.view
{
	import flash.display.MovieClip;
	import org.osflash.signals.Signal;
	import com.nudoru.nori.mvc.view.IAbstractNoriView;

	/**
	 * @author Matt Perkins
	 */
	public interface IUIView extends IAbstractNoriView
	{
		
		function get ui():MovieClip;
		
		function get navNextClickSignal():Signal
		function get navBackClickSignal():Signal
		function get navExitClickSignal():Signal
		
		function enableBackButton():void;
		function disableBackButton():void;
		function enableNextButton():void;
		function disableNextButton():void;
		function setTitle(text:String):void;
		function setPageNumber(text:String):void;
		
	}
}
