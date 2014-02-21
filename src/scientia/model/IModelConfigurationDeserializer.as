package scientia.model
{
	import scientia.model.VOs.ConfigVO;
	import scientia.model.VOs.ThemeVO;
	import scientia.model.structure.IStructureVO;
	/**
	 * @author Matt Perkins
	 */
	public interface IModelConfigurationDeserializer
	{

		function get configVO():ConfigVO;
		function get structureVO():IStructureVO;
		function get themeVO():ThemeVO;
		function process(xmlData:XML):void;
		
	}
}
