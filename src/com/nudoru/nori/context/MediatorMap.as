package com.nudoru.nori.context
{
	import com.nudoru.nori.context.ioc.IInjector;
	import com.nudoru.nori.context.ioc.IReflector;
	import com.nudoru.nori.mvc.view.IAbstractMediator;
	import com.nudoru.nori.mvc.view.IAbstractNoriView;
	import flash.utils.Dictionary;
	
	/**
	 * Mediator Mapping inspired by RobotLegs (of course)
	 * Implementation details helped by John Lindquist's video:
	 * 		http://johnlindquist.com/2011/02/03/how-it-works-robotlegs-part-3/
	 * 
	 * View Classes are mapped via the fully qualified class name (string) rather than the Class
	 * 	ala Robotlegs, allows Classes that the VM doesn't yet know about to be mapped
	 * 
	 * @author Matt Perkins
	 */
	public class MediatorMap implements IMediatorMap
	{
		
		private var _map:Dictionary = new Dictionary(true);
		private var _injector:IInjector;
		private var _reflector:IReflector;
		private var _mediatorInstances:Dictionary = new Dictionary(true);
		
		public function get injector():IInjector
		{
			return _injector;
		}

		[Inject]
		public function set injector(injector:IInjector):void
		{
			_injector = injector;
		}
		
		public function get reflector():IReflector
		{
			return _reflector;
		}

		[Inject]
		public function set reflector(reflector:IReflector):void
		{
			_reflector = reflector;
		}
		
		public function MediatorMap() {}
		
		/**
		 * Maps a mediator class to a view class
		 */
		public function map(viewClass:*, mediatorClass:Class):void
		{
			var viewClassName:String = getViewFQCN(viewClass);
			
			if(!hasMediatorMapped(viewClass))
			{
				_map[viewClassName] = mediatorClass;
			}
		}
		
		/**
		 * Removes mapping of a mediator to a view
		 */
		public function unmap(viewClass:*):void
		{
			if(hasMediatorMapped(viewClass))
			{
				var viewClassName:String = getViewFQCN(viewClass);
				delete _map[viewClassName];
				// TODO scan _mediatorInstances and remove any mediator instances to remove?
			}
		}
		
		/**
		 * True if there is a mediator mapped to the view class
		 */
		public function hasMediatorMapped(viewClass:*):Boolean
		{
			var viewClassName:String = getViewFQCN(viewClass);
			if(_map[viewClassName]) return true;
			return false;
		}
		
		/**
		 * Returns the mediator class that's mapped to the view class
		 */
		public function getMediatorClass(viewClass:*):Class
		{
			if(hasMediatorMapped(viewClass))
			{
				var viewClassName:String = getViewFQCN(viewClass);
				return _map[viewClassName] as Class;
			}
			return undefined;
		}

		/**
		 * Creates and instantiates the mediator class that's mapped to the view class
		 * View instance is the actual instance of the view that was created, it's injected into the mediator here
		 * The view must be extends AbstractNoriView to be eligible for automatic mediation
		 */
		public function createMediator(viewInstance:IAbstractNoriView):void
		{
			var viewClass:Class = reflector.getClass(viewInstance); 
			var viewClassName:String = getViewFQCN(viewClass);
			
			if(hasMediatorMapped(viewClass))
			{
				var mediatorClass:Class = getMediatorClass(viewClass);
				var mediatorInstance:IAbstractMediator = new mediatorClass();
				mediatorInstance.viewComponent = viewInstance;
				injector.injectInto(mediatorInstance);
				_mediatorInstances[viewClassName] = mediatorInstance;
				
				trace("MediatorMap created mediator "+mediatorClass+" for view class "+viewInstance);
		
			}
		}

		private function getViewFQCN(viewClassOrInstance:*):String
		{
			return reflector.getFQCN(viewClassOrInstance);
		}
		
	}
}
