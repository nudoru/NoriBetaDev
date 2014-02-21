package screen.model
{
	/**
	 * @author Matt Perkins
	 */
	public interface IAbstractScreenModel
	{
		function get id():String;
		function get type():String;
		function get title():String;
		function get text():String;
		function get cta():String;
		function get sheetXML():XML;
	}
}
