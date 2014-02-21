package com.nudoru.nori.events
{
	import com.nudoru.nori.context.ioc.IInjector;
	import com.nudoru.utilities.ArrayUtilities;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;



	/**
	 * Mapping code based on SignalsCircuit by Omar Gonzalez omar@laflash.org - https://github.com/s9tpepper/SignalsCircuit-for-PureMVC
	 * 
	 * @author Omar Gonzalez
	 * @author Matt Perkins
	 */ 
	public class CommandMap extends EventDispatcher implements ICommandMap
	{
		
		private var _verbose					:Boolean;

		private var _injector					:IInjector;
		
		private var _eventsMap 					:Dictionary = new Dictionary(true);
		private var _evtObserverMap				:Dictionary = new Dictionary(true);
		// list of all registered types for map destruction
		private var _registeredEventTypesList	:Vector.<String> = new Vector.<String>();
		
		private var _signalsMap					:Dictionary = new Dictionary(true);
		private var _sigObserverMap				:Dictionary = new Dictionary(true);
		// list of all registered signals for map destruction
		private var _registeredSignalsList		:Vector.<Signal> = new Vector.<Signal>();
		
		/**
		 * Toggles the amount of information that is traced as part of the debug output
		 */
		public function get verbose():Boolean { return _verbose; }
		/**
		 * 
		 * @param value
		 * 
		 */
		public function set verbose(value:Boolean):void { _verbose = value; }

		public function get injector():IInjector
		{
			return _injector;
		}

		[Inject]
		public function set injector(injector:IInjector):void
		{
			_injector = injector;
		}
		
		/**
		 * Constructor
		 */
		public function CommandMap() 
		{
			_verbose = true;
		}
		
		/**
		 * Closes out the event map
		 */
		public function destroy():void
		{
			for(var e:int=0; e<_registeredEventTypesList.length; e++)
			{
				removeEventCommand(_registeredEventTypesList[e]);
			}
			
			for(var s:int=0; s<_registeredSignalsList.length; s++)
			{
				removeSignalCommand(_registeredSignalsList[s]);
			}
			
			_registeredEventTypesList = new Vector.<String>();
			_registeredSignalsList = new Vector.<Signal>();
		}
		
		/**
		 * Inject depenancies and execute the command for Event or Signal based commands
		 */
		protected function executeCommand(commandInstance:*, signal:Signal=undefined, args:Array=undefined, event:Event=undefined):void
		{
			// injectables
			injector.injectInto(commandInstance);
			// these vary and don't have injection rules mapped
			commandInstance.event = event;
			commandInstance.signal = signal;
			commandInstance.data = args;
			// run it
			commandInstance.execute();
		}
		
		//---------------------------------------------------------------------
		//
		//	EVENTS
		//
		//---------------------------------------------------------------------
	
		/**
		 * Associates an event type broadcast from EventMap with a command. Uses the event type string as the key
		 * so all event types must be unique
		 * 
		 * @param	name	Event type to associate with command
		 * @param	cmd	Command to run when the event is dispatched from EventMap
		 */
		public function mapEventCommand(eventType:String, cmd:Class):void 
		{
			if (!hasEventCommand(eventType))
			{
				_eventsMap[eventType] = new cmd();
				_evtObserverMap[eventType] = new EventObserver(eventType, executeEventCommand, this);
				
				_registeredEventTypesList.push(eventType);
			}
		}

		/**
		 * Executes a Nori Command
		 * Creates the command and injects 
		 * 
		 * @param	cmd Command to execute
		 * @param	event	Pass an event to the command to get data from
		 */
		public function executeEventCommand(event:Event):void 
		{
			var commandInstance:*;
			if (_eventsMap[event.type] is Class)
			{
				var commandClassRef:Class = _eventsMap[event.type] as Class;
				if (commandClassRef == null) return;
				commandInstance = new commandClassRef();
			}
			else
			{
				commandInstance = _eventsMap[event.type];
			}
			
			if (commandInstance) executeCommand(commandInstance, undefined, [], event);
		}
		
		/**
		 * Removes handlers from the signal.
		 * 
		 * @param signal The Signal object to remove from the SignalsCircuit registry.
		 */
		public function removeEventCommand(eventType:String):void
		{
			if (hasEventCommand(eventType))
			{
				var eventObserver:EventObserver = _evtObserverMap[eventType] as EventObserver;
				eventObserver.destroy();
				delete _eventsMap[eventType];
				delete _evtObserverMap[eventType];
				
				_registeredEventTypesList = ArrayUtilities.deleteValueInArray(eventType, _registeredEventTypesList);
			}
		}
		/**
		 * Checks if the Event type has been registered with an INoriCommand
		 * 
		 * @param eventType
		 */
		public function hasEventCommand(eventType:String):Boolean
		{ 
			return (_eventsMap[eventType]) ? true : false;
		}

		//---------------------------------------------------------------------
		//
		//	SIGNALS
		//
		//---------------------------------------------------------------------
		
		/**
		 * Registers a Signal object and a ISignalCommand object together.
		 * 
		 * @param signal A Signal object to register a ISignalCommand object to.
		 * @param commandClassRef A Class reference to a sub-class of either SimpleSignalCommand or MacroSignalCommand
		 * @param cache A Boolean flag to set whether the Signal command object is cached (pre-instantiated).  For Signals that will dispatch many times this flag should be set to true to cut down on object instantiations and increase the speed performance.
		 */
		public function mapSignalCommand(signal:Signal, cmd:Class, cache:Boolean = true):void 
		{
			if (!hasSignalCommand(signal)) 
			{
				_signalsMap[signal]	= (cache) ? new cmd() : cmd;
				_sigObserverMap[signal] = new SignalObserver(signal, executeSignalCommand, this);
				
				_registeredSignalsList.push(signal);
			}
		}
		
		/**
		 * Executes the Command associated with a Signal object.
		 * This method is not intended for direct use, it is used by the
		 * SignalObserver object.
		 * 
		 * @param signal The Signal object that was heard by a SignalObserver instance.
		 * @param args An Array of arguments dispatched with the Signal object.
		 */
		public function executeSignalCommand(signal:Signal, args:Array):void 
		{
			var commandInstance:*;
			if (_signalsMap[signal] is Class)
			{
				var commandClassRef:Class = _signalsMap[signal] as Class;
				if (commandClassRef == null) return;
				commandInstance = new commandClassRef();
			}
			else
			{
				commandInstance = _signalsMap[signal];
			}
			
			if (commandInstance) executeCommand(commandInstance, signal, args);
		}
		
		
		/**
		 * Removes handlers from the signal.
		 * 
		 * @param signal The Signal object to remove from the SignalsCircuit registry.
		 */
		public function removeSignalCommand(signal:Signal):void
		{
			if (hasSignalCommand(signal))
			{
				var signalObserver:SignalObserver = _sigObserverMap[signal] as SignalObserver;
				signalObserver.destroy();
				
				delete _signalsMap[signal];
				delete _sigObserverMap[signal];
				
				_registeredSignalsList = ArrayUtilities.deleteValueInArray(signal, _registeredSignalsList);
			}
		}
		/**
		 * Checks if the Signal object has been registered with an ISignalCommand object.
		 * 
		 * @param signal A Signal object to check if it is active in the SignalsCircuit registry.
		 */
		public function hasSignalCommand(signal:Signal):Boolean
		{ 
			return (_signalsMap[signal]) ? true : false;
		}

		
	}
	
}