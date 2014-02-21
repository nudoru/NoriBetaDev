package scientia.view
{
	import com.nudoru.nori.mvc.view.IAbstractNoriView;
	import org.osflash.signals.Signal;
	import scientia.model.structure.IScreenVO;

	
	public interface IScreenManager extends IAbstractNoriView
	{

		function get isShowingScreen():Boolean;
		function get currentLoadedScreen():Object;
		
		function get onScreenShowSignal():Signal;
		function get onScreenLoadBeginSignal():Signal;
		function get onScreenLoadedSignal():Signal;
		function get onScreenLoadErrorSignal():Signal;
		function get onScreenInitializedSignal():Signal;
		function get onScreenRenderedSignal():Signal;
		function get onScreenUnloadedSignal():Signal;
		
		function showScreenSWF(screen:IScreenVO,ndirection:int=0):void;

	}
}