package scientia.model
{
	/**
	 * @author Matt Perkins
	 */
	public interface IModelMomentoProcessor
	{
		function getMomento():String;
		function processMomento(data:String):Boolean;
		
	}
}
