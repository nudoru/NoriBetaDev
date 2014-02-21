package com.nudoru.nori.mvc.controller 
{
	import com.nudoru.nori.mvc.Actor;
	import com.nudoru.nori.mvc.model.IAbstractModel;
	import com.nudoru.nori.mvc.view.IAbstractNoriView;

	/**
	 * Very basic MVC Controller class.
	 * This class is here to server as a template class since a true controller will be specific to
	 * your projects implementation of Nori. Not the abstract model and view used here.
	 * 
	 * @author Matt Perkins
	 */
	public class AbstractController extends Actor implements IAbstractController
	{
		private var _model:IAbstractModel;
		private var _view:IAbstractNoriView;

		/**
		 * Reference to the model
		 * @return 
		 */
		public function get model():IAbstractModel 
		{
			return _model;
		}
		
		/**
		 * Refernece to the model
		 * @param value
		 */
		[Inject]
		public function set model(value:IAbstractModel):void 
		{
			_model = value;
		}

		/**
		 * Reference to the view
		 * @return 
		 */
		public function get view():IAbstractNoriView
		{
			return _view;
		}
		
		/**
		 * Reference to the view
		 * @param value
		 */
		[Inject]
		public function set view(value:IAbstractNoriView):void 
		{
			_view = value;
		}

		/**
		 * Construcutor
		 */
		public function AbstractController() { }

		/**
		 * Initialize the controller
		 */
		[PostConstruct]
		public function initialize():void { }
		
		/**
		 * Starts the controller running
		 */
		public function start():void
		{
		}

	}

}