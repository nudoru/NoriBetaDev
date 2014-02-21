package scientia.model.structure
{
	/**
	 * Value object of a module
	 */
	public class ModuleVO extends NodeVO implements IModuleVO
	{

		public function ModuleVO(d:XML):void
		{
			super(d);
			parseXML();
		}

		override protected function parseXML():void
		{
			for(var i:int = 0, len:int = _SourceData.children().length(); i < len; i++)
			{
				_Children.push(new ScreenVO(_SourceData.children()[i] as XML));
			}
		}

	}
}