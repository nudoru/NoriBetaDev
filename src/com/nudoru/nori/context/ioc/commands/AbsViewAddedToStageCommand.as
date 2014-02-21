package com.nudoru.nori.context.ioc.commands 
{
	import com.nudoru.debug.Debugger;
	import com.nudoru.nori.context.IMediatorMap;
	import com.nudoru.nori.context.ioc.IReflector;
	import com.nudoru.nori.mvc.controller.commands.AbstractCommand;
	import com.nudoru.nori.mvc.controller.commands.IAbstractCommand;
	import com.nudoru.nori.mvc.view.IAbstractNoriView;
	
	/**
	 * The purpose of this command is to provide autowiring to each new view as they are added
	 * to the stage
	 */
	public class AbsViewAddedToStageCommand extends AbstractCommand implements IAbstractCommand
	{
		
		private var _mediatorMap:IMediatorMap;
		private var _relfector:IReflector;
		
		public function get mediatorMap():IMediatorMap
		{
			return _mediatorMap;
		}

		[Inject]
		public function set mediatorMap(value:IMediatorMap):void
		{
			_mediatorMap = value;
		}
		
		public function get relfector():IReflector
		{
			return _relfector;
		}

		[Inject]
		public function set relfector(relfector:IReflector):void
		{
			_relfector = relfector;
		}
		
		public function AbsViewAddedToStageCommand():void
		{
			super();
		}
		
		/**
		 * 
		 */
		override public function execute():void {
			trace("AbsViewAddedToStageCommand: "+data[0]);
			
			var view:IAbstractNoriView = data[0] as IAbstractNoriView;

			// if the view had autoWire = true, then inject
			if(Object(view).autoWire)
			{
				//Debugger.instance.add("AutoWiring view: "+data[0], this);
				injector.injectInto(view);
			}
			
			// create a mediator for the view if one is mapped
			mediatorMap.createMediator(view);
		}

	}

}