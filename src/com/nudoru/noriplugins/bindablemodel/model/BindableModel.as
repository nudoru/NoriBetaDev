package com.nudoru.noriplugins.bindablemodel.model
{
	import com.nudoru.nori.mvc.model.AbstractModel;
	import com.nudoru.noriplugins.bindablemodel.model.bind.PropertyChangedVO;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	/**
	 * Adds data binding functionality to the abstract model
	 * Usage:
	 * 
	 * 	To set up a property to be bound:
	 * 		public function set bind_prop(value:String):void
	 * 		{
	 * 			bind_prop_field = value;
	 * 			dispatchPropertyChange("bind_prop", bind_prop_field [, old_value]);		// this is the important line
	 * 		}
	 * 	
	 * 	To bind the property:
	 * 		bindable_model.bindProperty("bind_prop", binding_listener_function);	
	 * 		bindable_model.bindtest = "hello!";
	 * 	
	 * 	The binding_listener_function may any function and as long as it takes the new property value as an argument
	 * 
	 * This class should be subclassed to create more enhanced functionality.
	 */
	public class BindableModel extends AbstractModel implements IBindableModel
	{
		/**
		 * Signal for simple binding
		 */
		protected var _onPropertyChangeSignal:Signal = new Signal(PropertyChangedVO);
		/**
		 * Map of the bindings
		 */
		protected var _bindingMap:Dictionary = new Dictionary(true);

		public function get onPropertyChangeSignal():Signal
		{
			return _onPropertyChangeSignal;
		}

		/**
		 * Binds a function to a property name
		 * @param propName Name of the property
		 * @param setter Function to call when the property changes. Must take the property's value as a param
		 * @param overwrite Will remove existing setters and assign a new one
		 */
		public function bindProperty(propName:String, setter:Function, overwrite:Boolean = false):void
		{
			if(overwrite) unbind(propName);

			if(! isPropertyBound(propName))
			{
				_bindingMap[propName] = setter;
			}
			// if the signal doesn't have any listeners yet, set it up
			if(onPropertyChangeSignal.numListeners)
			{
				onPropertyChangeSignal.add(handlePropertyChanged);
			}
		}

		/**
		 * Remove the bindings for a property
		 */
		public function unbind(propName:String):void
		{
			if(isPropertyBound(propName))
			{
				delete _bindingMap[propName];
			}
		}

		/**
		 * Determins if the property is bound to anything
		 */
		protected function isPropertyBound(propName:String):Boolean
		{
			return (_bindingMap[propName]) ? true : false;
		}

		/**
		 * Called from a setter to notify bindings of a change to the value
		 */
		protected function dispatchPropertyChange(name:String, value:*, oldvalue:*=undefined):void
		{
			if(isPropertyBound(name))
			{
				var vo:PropertyChangedVO = new PropertyChangedVO(name, value, oldvalue);
				onPropertyChangeSignal.dispatch(vo);
			}
		}

		/**
		 * Listener for the onPropertyChangeSignal signal and notifys bound setter
		 */
		protected function handlePropertyChanged(changeObject:PropertyChangedVO):void
		{
			if(isPropertyBound(changeObject.name))
			{
				var func:Function = _bindingMap[changeObject.name] as Function;
				func.call(this, changeObject.value);
			}
		}

		/**
		 * Construtor
		 */
		public function BindableModel()
		{
			super();
		}
	}
}