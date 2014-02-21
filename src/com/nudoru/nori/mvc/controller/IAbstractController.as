package com.nudoru.nori.mvc.controller
{
	import com.nudoru.nori.mvc.IActor;
	import com.nudoru.nori.mvc.model.IAbstractModel;
	import com.nudoru.nori.mvc.view.IAbstractNoriView;

	/**
	 * Template Data type for a controller class
	 */
	public interface IAbstractController extends IActor
	{
		function get model():IAbstractModel;
		function set model(value:IAbstractModel):void;
		function get view():IAbstractNoriView;
		function set view(value:IAbstractNoriView):void;
		function initialize():void;
		function start():void;
	}

}