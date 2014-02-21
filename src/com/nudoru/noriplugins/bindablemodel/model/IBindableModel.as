package com.nudoru.noriplugins.bindablemodel.model
{
	import com.nudoru.nori.mvc.model.IAbstractModel;
	import org.osflash.signals.Signal;

	/**
	 * Data type for a bindable model class
	 */
	public interface IBindableModel extends IAbstractModel
	{
		function get onPropertyChangeSignal():Signal;
		function bindProperty(propName:String, setter:Function, overwrite:Boolean = false):void;
		function unbind(propName:String):void;
	}

}