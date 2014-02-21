package com.nudoru.nori.mvc.model 
{
	import com.nudoru.nori.mvc.Actor;

	/**
	 * Very basic MVC Model class.
	 * This class should be subclassed to create more enhanced functionality.
	 */
	public class AbstractModel extends Actor implements IAbstractModel
	{	

		public function AbstractModel() 
		{
		}
	
		/**
		 * Initializes the model
		 */
		[PostConstruct]
		public function initialize():void 
		{
		}

	}

}