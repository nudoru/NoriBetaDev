package screen.model
{
	import com.nudoru.lms.scorm.InteractionObject;
	/**
	 * @author Matt Perkins
	 */
	public interface IInteractionObjectFactory
	{
		
		function create():InteractionObject;
		function getCorrectResponsePattern():Array;
		function getLearnerResponsePattern():String;
		
	}
}
