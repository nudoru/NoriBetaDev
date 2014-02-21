package scientia.view
{
	import com.nudoru.constants.ObjectStatus;
	import com.nudoru.lms.scorm.InteractionObject;
	import com.nudoru.nori.context.ioc.IInjector;
	import com.nudoru.nori.mvc.view.AbstractMediator;
	import scientia.model.IScientiaModel;
	import scientia.model.structure.IScreenVO;
	import screen.events.signals.ScreenStatusSignals;

	/**
	 * Manages communication between a loaded screen (in the ScreenManager) and the rest of the Scientia App
	 * 
	 * @author Matt Perkins
	 */
	public class ScreenManagerMediator extends AbstractMediator implements IScreenManagerMediator
	{
		
		private var _model			:IScientiaModel;
		private var _injector			:IInjector;
		
		private var _currentScreenVO	:IScreenVO;
		
		public function get model():IScientiaModel
		{
			return _model;
		}

		[Inject]
		public function set model(model:IScientiaModel):void
		{
			_model = model;
		}
		
		public function get injector():IInjector
		{
			return _injector;
		}

		[Inject]
		public function set injector(injector:IInjector):void
		{
			_injector = injector;
		}
		
		//---------------------------------------------------------------------
		//
		//	CONSTRUCTOR/INITIALIZATION
		//
		//---------------------------------------------------------------------
		
		public function ScreenManagerMediator()
		{
		}

		override public function onRegister():void
		{
			var mediatedView:IScreenManager = viewComponent as ScreenManager;
			
			mediatedView.onScreenShowSignal.add(onScreenShow);
			mediatedView.onScreenLoadBeginSignal.add(onScreenLoadBegin);
			mediatedView.onScreenLoadedSignal.add(onScreenLoaded);
			mediatedView.onScreenLoadErrorSignal.add(onScreenLoadError);
			mediatedView.onScreenInitializedSignal.add(onScreenInitialized);
			mediatedView.onScreenRenderedSignal.add(onScreenRendered);
			mediatedView.onScreenUnloadedSignal.add(onScreenUnloaded);
			
			ScreenStatusSignals.INCOMPLETE.add(onScreenStatusIncomplete);
			ScreenStatusSignals.COMPLETED.add(onScreenStatusComplete);
			ScreenStatusSignals.PASSED.add(onScreenStatusPass);
			ScreenStatusSignals.FAILED.add(onScreenStatusFail);
		}

		//---------------------------------------------------------------------
		//
		//	EVENTS/SIGNALS FOR SCREEN STATE
		//
		//---------------------------------------------------------------------
		
		private function onScreenShow(screen:IScreenVO):void
		{
			_currentScreenVO = screen;
		}
		
		private function onScreenLoadBegin():void
		{
			//trace("onScreenLoadBegin");
		}

		private function onScreenLoaded():void
		{
			//trace("onScreenLoaded");
			
			// If you're here because you're toubleshooting injection, make sure the screen SWF is being
			// published as a SWC also. This is required to preserve metadata
			injector.injectInto(viewComponent.currentLoadedScreen);
			var currentScreenVO:IScreenVO = model.getCurrentScreen();
			viewComponent.currentLoadedScreen.initialize( { status:currentScreenVO.status, 
															interobj:currentScreenVO.interactionObject, 
															xmlurl:currentScreenVO.dataURL } );
		}

		private function onScreenLoadError():void
		{
			//trace("onScreenLoadError");
		}

		private function onScreenInitialized():void
		{
			//trace("onScreenInitialized");
		}

		private function onScreenRendered():void
		{
			//trace("onScreenRendered");
		}

		private function onScreenUnloaded():void
		{
			//trace("onScreenUnloaded");
		}

		//---------------------------------------------------------------------
		//
		//	EVENTS/SIGNALS FOR SCREEN STATUS
		//
		//---------------------------------------------------------------------

		private function onScreenStatusIncomplete():void
		{
			model.setScreenIDStatusInteractionObjectAndBroadcast(_currentScreenVO.id, ObjectStatus.INCOMPLETE, undefined);
		}

		private function onScreenStatusComplete(interactionobject:InteractionObject):void
		{
			model.setScreenIDStatusInteractionObjectAndBroadcast(_currentScreenVO.id, ObjectStatus.COMPLETED, interactionobject);
		}

		private function onScreenStatusPass(interactionobject:InteractionObject):void
		{
			model.setScreenIDStatusInteractionObjectAndBroadcast(_currentScreenVO.id, ObjectStatus.PASSED, interactionobject);
		}
		
		private function onScreenStatusFail(interactionobject:InteractionObject):void
		{
			model.setScreenIDStatusInteractionObjectAndBroadcast(_currentScreenVO.id, ObjectStatus.FAILED, interactionobject);
		}

		//---------------------------------------------------------------------
		//
		//	DESTROY
		//
		//---------------------------------------------------------------------

		override public function destroy():void
		{
			viewComponent.onScreenLoadBeginSignal.remove(onScreenLoadBegin);
			viewComponent.onScreenLoadedSignal.remove(onScreenLoaded);
			viewComponent.onScreenLoadErrorSignal.remove(onScreenLoadError);
			viewComponent.onScreenInitializedSignal.remove(onScreenInitialized);
			viewComponent.onScreenRenderedSignal.remove(onScreenRendered);
			viewComponent.onScreenUnloadedSignal.remove(onScreenUnloaded);
			
			ScreenStatusSignals.INCOMPLETE.remove(onScreenStatusIncomplete);
			ScreenStatusSignals.COMPLETED.remove(onScreenStatusComplete);
			ScreenStatusSignals.PASSED.remove(onScreenStatusPass);
			ScreenStatusSignals.FAILED.remove(onScreenStatusFail);
			
			super.destroy();
		}

	}
}
