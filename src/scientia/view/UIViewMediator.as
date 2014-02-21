package scientia.view
{
	import scientia.events.signals.NavigationSignals;
	import com.nudoru.nori.mvc.view.AbstractMediator;

	/**
	 * @author Matt Perkins
	 */
	public class UIViewMediator extends AbstractMediator implements IUIViewMediator
	{
		
		//---------------------------------------------------------------------
		//
		//	CONSTRUCTOR/INITIALIZATION
		//
		//---------------------------------------------------------------------
		
		public function UIViewMediator()
		{
		}
		
		override public function onRegister():void
		{
			var mediatedView:IUIView = viewComponent as IUIView;
			
			mediatedView.navBackClickSignal.add(onBackClickSignal);
			mediatedView.navNextClickSignal.add(onNextClickSignal);
			mediatedView.navExitClickSignal.add(onExitClickSignal);
		}

		//---------------------------------------------------------------------
		//
		//	EVENTS/SIGNALS
		//
		//---------------------------------------------------------------------

		private function onBackClickSignal():void
		{
			NavigationSignals.GOTO_PREVIOUS_SCREEN.dispatch();
		}

		private function onNextClickSignal():void
		{
			NavigationSignals.GOTO_NEXT_SCREEN.dispatch();
		}
		
		private function onExitClickSignal():void
		{
			NavigationSignals.EXIT.dispatch();
		}
		
		//---------------------------------------------------------------------
		//
		//	DESTROY
		//
		//---------------------------------------------------------------------
		
		override public function destroy():void
		{
			var mediatedView:IUIView = viewComponent as IUIView;
			
			mediatedView.navBackClickSignal.remove(onBackClickSignal);
			mediatedView.navNextClickSignal.remove(onNextClickSignal);
			mediatedView.navExitClickSignal.remove(onExitClickSignal);
		}
		
	}
}
