package scientia.model 
{
	import scientia.model.VOs.ConfigVO;
	import scientia.model.VOs.ThemeVO;
	import scientia.model.structure.IStructureVO;
	import scientia.model.structure.StructureVO;

	/**
	 * Utility class to parse the XML and creates VOs for the mode
	 * 
	 * @author Matt Perkins
	 */
	public class ModelConfigurationDeserializer implements IModelConfigurationDeserializer
	{
		
		private var _configVO			:ConfigVO;
		private var _structureVO		:IStructureVO;
		private var _themeVO			:ThemeVO;

		public function get configVO():ConfigVO
		{
			return _configVO;
		}

		public function get structureVO():IStructureVO
		{
			return _structureVO;
		}

		public function get themeVO():ThemeVO
		{
			return _themeVO;
		}

		public function ModelConfigurationDeserializer():void
		{
		}

		/**
		 * Converts the XML into the VOs needed by the model
		 * @param	xmlData
		 */
		public function process(xmlData:XML):void
		{
			_configVO = new ConfigVO();
			_configVO.name = xmlData.settings.name;
			_configVO.author = xmlData.settings.author;
			_configVO.lastModified = xmlData.settings.lastmodified;
			_configVO.audioEnable = (xmlData.settings.audioenabled == "true");
			_configVO.useSWFAddress = (xmlData.settings.useswfaddress == "true");
			_configVO.useLSO = (xmlData.settings.uselso == "true");
			_configVO.clearLSO = (xmlData.settings.clearlso == "true");

			_configVO.lmsMode = xmlData.settings.lms.mode;
			_configVO.lmsCompletionCriteria = xmlData.settings.lms.completioncriteria;
			_configVO.lmsAllowFailingStatus =(xmlData.settings.lms.allowfailingstatus == "true");
			_configVO.lmsPassingScore = int(xmlData.settings.lms.passingscore);

			_themeVO = new ThemeVO();
			_themeVO.scaleView = (xmlData.settings.theme.scaleui == "true");
			_themeVO.assetsSWF = xmlData.settings.theme.assets;
			_themeVO.highLightColor = Number(xmlData.settings.theme.highlightcolor);
			_themeVO.colors = String(xmlData.settings.theme.colors).split(",");
			_themeVO.fonts = String(xmlData.settings.theme.fonts).split(",");
			
			_configVO.themeVO = _themeVO;
			
			_structureVO = new StructureVO(XML(xmlData).structure[0]);
		}

	}

}