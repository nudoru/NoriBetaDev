package com.nudoru.nori.events
{
	import org.osflash.signals.Signal;


	/**
	 * Modification of Omar Gonzalez's SignalObserver class to support Nori
	 * 
	 * @author Omar Gonzalez
	 * @author Matt Perkins
	 */
	public class SignalObserver
	{
		private var _notify:Function;
		private var _context:ICommandMap;
		private var _signal:Signal;

		/**
		 * @Constructor
		 * 
		 * @param signal Signal object to watch for signals.
		 * @param notifyMethod Function callback to notify/invoke.
		 * @param notifyContext Object on which the function callback exists.
		 */
		public function SignalObserver(signal:Signal, notifyMethod:Function, notifyContext:ICommandMap)
		{
			_notify = notifyMethod;
			_context = notifyContext;

			_initSignal(signal);
		}

		/**
		 * Initializes the Signal object.
		 * 
		 * @param signal Signal object to watch for dispatched signals.
		 */
		private function _initSignal(signal:Signal):void
		{
			_signal = signal;
			_signal.add(_signalWatcher);
		}

		/**
		 * The method that watches for dispatches from the signal, notifies
		 * the observers.
		 * 
		 * @param firstArg
		 * @param rest
		 */
		private function _signalWatcher(firstArg:*=null, ... rest):void
		{
			if (firstArg == null) _signalObservers(_signal, null);
			else if (firstArg && !rest) _signalObservers(_signal, [firstArg]);
			else
			{
				rest.unshift(firstArg);
				_signalObservers(_signal, rest);
			}

			/* Implementation using switch statement caused stack error with "true"
			switch (true)
			{
			case (firstArg == null):
			_signalObservers(_signal, null);
			break;
			case (firstArg && !rest):
			_signalObservers(_signal, [firstArg]);
			break;
					
			default:
			rest.unshift(firstArg);
			_signalObservers(_signal, rest);
			break;
			}*/
		}

		/**
		 * Sends the signal to all observers of this Signal object dispatches.
		 */
		private function _signalObservers(signal:Signal, args:Array):void
		{
			_notify(signal, args);
		}

		/**
		 * Compare an object to the notification context. 
		 * 
		 * @param object the object to compare
		 * @return boolean indicating if the object and the notification context are the same
		 */
		public function compareNotifyContext(object:Object):Boolean
		{
			return object === this._context;
		}

		/**
		 * Destroys the SignalObserver object.
		 */
		public function destroy():void
		{
			if (_signal)
			{
				_signal.remove(_signalWatcher);
			}

			_context = null;
			_notify = null;
			_signal = null;
		}

		/**
		 * Returns the Signal object associated with this SignalObserver instance.
		 */
		public function get signal():Signal
		{
			return _signal;
		}
	}
}
