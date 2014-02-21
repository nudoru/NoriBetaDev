package scientia.model.VOs 
{
	import com.nudoru.nori.mvc.model.VOs.IAbstractVO;

	/**
	 * Configuration object for the Nori Framework/Mode
	 */
	public class ConfigVO implements IAbstractVO
	{
		/**
		 * Name of the project
		 */
		public var name			:String;
		/**
		 * Developer of the project
		 */
		public var author		:String;
		/**
		 * Date when the project was last modified
		 */
		public var lastModified	:String;
		/**
		 * URL of the content file
		 */
		public var contentURL	:String;
		/**
		 * Audio enabled
		 */
		public var audioEnable	:Boolean;
		/**
		 * Use SWFAddress
		 */
		public var useSWFAddress:Boolean;
		/**
		 * Use shared object to store local information
		 */
		public var useLSO		:Boolean;
		/**
		 * Clear the LSO object
		 */
		public var clearLSO		:Boolean;
		/**
		 * Settings for the look and feel
		 */
		public var themeVO		:ThemeVO;
		/**
		 * LMS Mode of operation
		 */
		public var lmsMode		:String;
		/**
		 * Course Completion Criteria
		 */
		public var lmsCompletionCriteria:String;
		/**
		 * Allow failing to be recorded or track it as incomplete
		 */
		public var lmsAllowFailingStatus:Boolean;
		/**
		 * Course completion score
		 */
		public var lmsPassingScore:int;
		
		
	}

}