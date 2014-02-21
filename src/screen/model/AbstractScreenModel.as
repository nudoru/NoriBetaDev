package screen.model
{

	/**
	 * Abstract for a screen model
	 * @author Matt Perkins
	 */
	public class AbstractScreenModel implements IAbstractScreenModel
	{
		public var _xml			:XML;
		
		public function get id():String { return String(_xml.@id); }
		public function get type():String { return String(_xml.@type); }
		
		public function get title():String { return String(_xml.title); }
		public function get text():String { return String(_xml.text); }
		public function get cta():String { return String(_xml.cta); }
		
		public function get sheetXML():XML { return _xml.sheet[0]; }

		public function get imageURL():String { return String(_xml.image.@url); }
		public function get imageWidth():int { return int(_xml.image.@width); }
		public function get imageHeight():int { return int(_xml.image.@height); }
		public function get imageX():int { return int(_xml.image.@x); }
		public function get imageY():int { return int(_xml.image.@y); }

		public function AbstractScreenModel(data:XML):void
		{
			_xml = data;
		}

	}
	
}