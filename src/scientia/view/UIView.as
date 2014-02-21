package scientia.view
{
	import org.osflash.signals.Signal;
	import com.greensock.easing.Quad;
	import com.greensock.TweenMax;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import com.nudoru.utilities.AccUtilities;
	import org.osflash.signals.natives.NativeSignal;
	import flash.display.MovieClip;
	import com.nudoru.nori.mvc.view.AbstractNoriView;

	/**
	 * @author Matt Perkins
	 */
	public class UIView extends AbstractNoriView implements IUIView
	{
		
		private var _uiAsset:MovieClip;
		private var _navNextClickNavSignal:NativeSignal;
		private var _navPrevClickNavSignal:NativeSignal;
		private var _navExitClickNavSignal:NativeSignal;
		
		private var _navNextClickSignal:Signal = new Signal();
		private var _navBackClickSignal:Signal = new Signal();
		private var _navExitClickSignal:Signal = new Signal();
		
		//---------------------------------------------------------------------
		//
		//	GETTER/SETTER
		//
		//---------------------------------------------------------------------
		
		public function get ui():MovieClip
		{
			return _uiAsset;
		}
		
		public function get navNextClickSignal():Signal
		{
			return _navNextClickSignal;
		}

		public function get navBackClickSignal():Signal
		{
			return _navBackClickSignal;
		}

		public function get navExitClickSignal():Signal
		{
			return _navExitClickSignal;
		}
		
		//---------------------------------------------------------------------
		//
		//	CONSTRUCTION/INIT
		//
		//---------------------------------------------------------------------
		
		public function UIView()
		{
			super();
		}

		override public function initialize(data:*=null):void
		{
			_uiAsset = data as MovieClip;
		}

		override public function render():void
		{
			this.addChild(_uiAsset);
			
			createUISignals();
			
			configureAccessibility();
		}
		
		private function createUISignals():void
		{
			_navPrevClickNavSignal = new NativeSignal(ui.back_btn, MouseEvent.CLICK, Event);
			_navPrevClickNavSignal.add(onBackClick);
			_navNextClickNavSignal = new NativeSignal(ui.next_btn, MouseEvent.CLICK, Event);
			_navNextClickNavSignal.add(onNextClick);
			_navExitClickNavSignal = new NativeSignal(ui.exit_btn, MouseEvent.CLICK, Event);
			_navExitClickNavSignal.add(onExitClick);
		}
		
		private function configureAccessibility():void
		{
			AccUtilities.setProperties(ui.exit_btn, "Exit Course");
			AccUtilities.setProperties(ui.back_btn, "Previous Page");
			AccUtilities.setProperties(ui.next_btn, "Next Page");
		}

		//---------------------------------------------------------------------
		//
		//	EVENTS/SIGNALS
		//
		//---------------------------------------------------------------------

		private function onExitClick(e:Event):void
		{
			navExitClickSignal.dispatch();
		}

		private function onBackClick(e:Event):void
		{
			if(ui.back_btn.alpha < 1 || ! ui.back_btn.enabled) return;
			navBackClickSignal.dispatch();
		}

		private function onNextClick(e:Event):void
		{
			if(ui.next_btn.alpha < 1 || ! ui.next_btn.enabled) return;
			navNextClickSignal.dispatch();
		}

		//---------------------------------------------------------------------
		//
		//	UI STATE
		//
		//---------------------------------------------------------------------

		public function enableBackButton():void
		{
			ui.back_btn.enabled = true;
			TweenMax.to(ui.back_btn, .25, {alpha:1, ease:Quad.easeOut});
		}

		public function disableBackButton():void
		{
			ui.back_btn.enabled = false;
			TweenMax.to(ui.back_btn, .25, {alpha:.25, ease:Quad.easeOut});
		}

		public function enableNextButton():void
		{
			ui.next_btn.enabled = true;
			TweenMax.to(ui.next_btn, .25, {alpha:1, ease:Quad.easeOut});
		}

		public function disableNextButton():void
		{
			ui.next_btn.enabled = false;
			TweenMax.to(ui.next_btn, .25, {alpha:.25, ease:Quad.easeOut});
		}
		
		//---------------------------------------------------------------------
		//
		//	UI TEXT
		//
		//---------------------------------------------------------------------
		
		// setst the title at the top of the UI
		public function setTitle(text:String):void
		{
			ui.title_txt.text = text;
		}
		
		/**
		 * Set the page number text field in the UI
		 * @param	text
		 */
		public function setPageNumber(text:String):void
		{
			ui.pagenumber_txt.text = text;
		}

		//---------------------------------------------------------------------
		//
		//	DESTROY
		//
		//---------------------------------------------------------------------

		override public function destroy():void
		{
			removeChild(_uiAsset);
			_uiAsset = undefined;
			
			super.destroy();
		}

	}
}
