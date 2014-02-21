package com.nudoru.nori.context 
{

	import com.nudoru.nori.context.ioc.IInjector;
	import com.nudoru.nori.context.ioc.IReflector;
	import com.nudoru.nori.context.ioc.commands.AbsViewAddedToStageCommand;
	import com.nudoru.nori.context.ioc.commands.AbsViewRemovedFromStageCommand;
	import com.nudoru.nori.events.CommandMap;
	import com.nudoru.nori.events.ICommandMap;
	import com.nudoru.nori.events.signals.AbstractViewSignals;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import org.osflash.signals.Signal;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.Reflector;



	/**
	 * Basic context providing core functionality
	 * @author Matt Perkins
	 */
	public class AbstractContext implements IAbstractContext
	{

		protected var _injector			:IInjector;
		protected var _reflector		:IReflector;

		protected var _contextView		:DisplayObjectContainer;

		protected var _mediatorMap		:IMediatorMap;

		/**
		 * To dispatch events with in the framework
		 */
		protected var _eventDispatcher	:IEventDispatcher;
		/**
		 * Event/signal/command mapping for the context
		 */
		protected var _commandMap			:ICommandMap;

		/**
		 * Dispatched when the context is fully initialized
		 * May tell the parent container to call the run() function
		 */
		public var contextInitialzedSignal		:Signal = new Signal();
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Getters

		/**
		 * IOC container
		 */
		public function get injector():IInjector
		{
			return _injector;
		}

		/**
		 * IOC Reflector
		 */
		public function get reflector():IReflector
		{
			return _reflector;
		}
		
		/**
		 * Event map
		 */
		public function get commandMap():ICommandMap
		{
			return _commandMap;
		}
		
		/**
		 * Mediator Map
		 */
		public function get mediatorMap():IMediatorMap
		{
			return _mediatorMap;
		}

		/**
		 * Reference to the root sprite or stage that created this context
		 */
		public function get contextView():DisplayObjectContainer 
		{
			return _contextView;
		}
		
		/**
		 * Reference to the context's event dispatcher
		 */
		public function get eventDispatcher():IEventDispatcher
		{
			return _eventDispatcher;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// Constructor
		
		/**
		 * Constructor
		 */
		public function AbstractContext():void
		{
			super();
		}
		
		/**
		 * Initializes the context with a link to the container of the context 
		 * @param cv
		 */
		public function initialize(cv:DisplayObjectContainer):void 
		{
			_contextView = cv;

			_injector = new Injector();
			_reflector = new Reflector();
			_mediatorMap = new MediatorMap();
			_commandMap = new CommandMap();
			_eventDispatcher = new EventDispatcher(cv);
			
			// important global maps
			injector.mapValue(IInjector, _injector);
			injector.mapValue(IReflector, _reflector);
			injector.mapValue(IAbstractContext, this);
			injector.mapValue(IMediatorMap, _mediatorMap);
			injector.mapValue(ICommandMap, _commandMap);
			injector.mapValue(IEventDispatcher, _eventDispatcher);
			injector.mapValue(DisplayObjectContainer, _contextView);
			
			injector.injectInto(_mediatorMap);
			injector.injectInto(_commandMap);
			
			commandMap.mapSignalCommand(AbstractViewSignals.ADDED_TO_STAGE, AbsViewAddedToStageCommand);
			commandMap.mapSignalCommand(AbstractViewSignals.REMOVED_FROM_STAGE, AbsViewRemovedFromStageCommand);
			
			onStartUp();
		}
		
		/**
		 * Startup point or entry hook to the context
		 */
		protected function onStartUp():void
		{
			trace("NEED TO OVERRIDE THE ABSTRACTCONTEXT STARTUP FUNCTION");
		}
		
		/**
		 * Need to override
		 */
		public function run():void 
		{
			trace("NEED TO OVERRIDE THE ABSTRACTCONTEXT RUN FUNCTION");
		}
		
		/**
		 * Destroys the context
		 */
		public function destroy():void
		{
			_commandMap.destroy();
			
			_injector = null;
			_reflector = null;
			_commandMap = null;
			_eventDispatcher = null;
			_contextView = null;
		}

		

		

	}

}