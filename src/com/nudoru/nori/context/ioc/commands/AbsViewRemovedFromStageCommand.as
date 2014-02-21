package com.nudoru.nori.context.ioc.commands 
{
	import com.nudoru.nori.context.IMediatorMap;
	import com.nudoru.nori.mvc.controller.commands.AbstractCommand;
	import com.nudoru.nori.mvc.controller.commands.IAbstractCommand;
	import com.nudoru.nori.mvc.view.IAbstractNoriView;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * Cleans up after a view is removed
	 */
	public class AbsViewRemovedFromStageCommand extends AbstractCommand implements IAbstractCommand
	{
		
		private var _mediatorMap:IMediatorMap;
		
		public function get mediatorMap():IMediatorMap
		{
			return _mediatorMap;
		}

		[Inject]
		public function set mediatorMap(value:IMediatorMap):void
		{
			_mediatorMap = value;
		}
		
		public function AbsViewRemovedFromStageCommand():void
		{
			super();
		}
		
		/**
		 * 
		 */
		override public function execute():void {
			trace("AbsViewRemovedFromStageCommand: "+data[0]);
			
			var view:IAbstractNoriView = data[0] as IAbstractNoriView;
			var qualifiedClassName:String = getQualifiedClassName(view);
			var definitionByName:Object = getDefinitionByName(qualifiedClassName);

			if(mediatorMap.hasMediatorMapped(definitionByName))
			{
				mediatorMap.unmap(definitionByName);
			}
		}
		
	}

}