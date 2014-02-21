package com.nudoru.nori.mvc.controller.commands 
{
	import com.nudoru.nori.context.ioc.IInjector;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import org.osflash.signals.Signal;

	public class AbstractCommand implements IAbstractCommand
	{

		protected var _event			:Event;
		protected var _signal			:Signal;
		protected var _data				:Array;
		protected var _eventDispatcher	:IEventDispatcher;
		protected var _injector			:IInjector;
		
		// injected data passed from the signal

		public function get event():Event 
		{
			return _event;
		}
		
		public function set event(value:Event):void 
		{
			_event = value;
		}
		
		public function get signal():Signal 
		{
			return _signal;
		}
		
		public function set signal(value:Signal):void 
		{
			_signal = value;
		}
		
		/**
		 * Returns data that the command should work with
		 * If there is data injected from a signal, return that
		 * Else if there is data from an injected event, return that
		 * Return nothing
		 */
		public function get data():Array
		{
			if(_data) return _data;
			return [];
		}
		
		public function set data(value:Array):void 
		{
			_data = value;
		}
		
		public function get eventDispatcher():IEventDispatcher
		{
			return _eventDispatcher;
		}

		[Inject]
		public function set eventDispatcher(eventDispatcher:IEventDispatcher):void
		{
			_eventDispatcher = eventDispatcher;
		}
		
		public function get injector():IInjector
		{
			return _injector;
		}
		
		[Inject]
		public function set injector(value:IInjector):void
		{
			_injector = value;
		}
		
		public function AbstractCommand():void
		{
			super();
		}

		public function execute():void {
			//
		}

	}

}