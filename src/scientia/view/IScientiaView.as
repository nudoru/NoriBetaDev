package scientia.view
{

	import com.nudoru.noriplugins.appview.view.IAppView;
	import scientia.model.structure.IScreenVO;

	public interface IScientiaView extends IAppView
	{

		function setTitle(text:String):void;
		function setPageNumber(text:String):void;
		
		function enableBackButton():void;
		function disableBackButton():void;
		function enableNextButton():void;
		function disableNextButton():void;
		
		function showScreen(screen:IScreenVO, ndirection:int = 0):void;
	}
}