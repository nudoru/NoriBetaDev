package scientia.controller.commands 
{
	import com.nudoru.nori.mvc.controller.commands.AbstractCommand;
	import scientia.model.IScientiaModel;
	import scientia.view.IScientiaView;

	public class AbstractScientiaCommand extends AbstractCommand implements IAbstractScientiaCommand
	{
		
		protected var _model			:IScientiaModel;
		protected var _view				:IScientiaView;

		public function get model():IScientiaModel 
		{
			return _model;
		}
		
		[Inject]
		public function set model(value:IScientiaModel):void 
		{
			_model = value;
		}
		
		public function get view():IScientiaView 
		{
			return _view;
		}
		
		[Inject] 
		public function set view(value:IScientiaView):void 
		{
			_view = value;
		}
		
		public function AbstractScientiaCommand():void
		{
			super();
		}

		override public function execute():void 
		{
		}
		
		
		
	}

}