package scientia.controller.commands
{
	import com.nudoru.nori.mvc.controller.commands.IAbstractCommand;
	import scientia.model.IScientiaModel;
	import scientia.view.IScientiaView;

	/**
	 * Data type for a command
	 */
	public interface IAbstractScientiaCommand extends IAbstractCommand
	{
		
		function get model():IScientiaModel;
		function set model(value:IScientiaModel):void;
		function get view():IScientiaView;
		function set view(value:IScientiaView):void;

	}
}