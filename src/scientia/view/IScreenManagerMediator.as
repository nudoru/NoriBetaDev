package scientia.view
{
	import com.nudoru.nori.context.ioc.IInjector;
	import com.nudoru.nori.mvc.view.IAbstractMediator;
	import scientia.model.IScientiaModel;
	
	public interface IScreenManagerMediator extends IAbstractMediator
	{
		function get model():IScientiaModel;
		function set model(model:IScientiaModel):void;
		function get injector():IInjector;
		function set injector(injector:IInjector):void;
	}
}