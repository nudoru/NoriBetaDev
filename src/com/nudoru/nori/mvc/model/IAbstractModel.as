package com.nudoru.nori.mvc.model
{
	import com.nudoru.nori.mvc.IActor;

	/**
	 * Data type for a model class
	 */
	public interface IAbstractModel extends IActor
	{
		function initialize():void;
	}

}