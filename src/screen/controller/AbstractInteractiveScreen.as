package screen.controller
{
	import com.greensock.TweenMax;
	import com.greensock.easing.*;

	import org.osflash.signals.natives.NativeSignal;

	import flash.display.*;
	import flash.events.*;
	
	/**
	 * Provide common functionality for all interactivity (question/list) screens
	 * @author Matt Perkins
	 */
	public class AbstractInteractiveScreen extends AbstractScreen implements IAbstractInteractiveScreen
	{
	
		//---------------------------------------------------------------------
		//
		//	VARIABLES
		//
		//---------------------------------------------------------------------
		
		/**
		 * Is the interaction disabled?
		 */
		protected var _interactivityEnabled	:Boolean = true;
		/**
		 * Array of interaction items: list items, choices
		 * Type is Array rather than the preferred Vector since it may vary between an ItemSprite and ChoiceSprite
		 */
		protected var _IObjects			:Array = [];	
		/**
		 * Sprite holder for the interactive objects
		 */
		protected var _IObjectHolder	:Sprite;
		/**
		 * Simple list of letters for alphabetic numbering
		 */
		protected var _LetterList		:Array = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
		
		/**
		 * Signals
		 */
		protected var _stageKeyPressNSignal	:NativeSignal;
		
		//---------------------------------------------------------------------
		//
		//	GETTER/SETTER
		//
		//---------------------------------------------------------------------
		
		/**
		 * Get the number of interactive objects
		 */
		protected function get numIObjects():int { return _IObjects.length; }
		
		
		//---------------------------------------------------------------------
		//
		//	CONSTRUCTION/INITIALIZATION
		//
		//---------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function AbstractInteractiveScreen():void
		{
			super();
		}

		//---------------------------------------------------------------------
		//
		//	VIEW / KEYPRESS
		//
		//---------------------------------------------------------------------

		/**
		 * Extend the render function to add interactive events
		 */
		override public function render():void
		{
			super.render();
			
			_stageKeyPressNSignal = new NativeSignal(this.stage, KeyboardEvent.KEY_DOWN, Event);
			_stageKeyPressNSignal.add(onKeyPress);
		}
		
		/**
		 * Render the interactive objects to the display
		 */
		protected function renderInteractiveObjects():void
		{
			//
		}
		
		/**
		 * Stop all animation and set to final state
		 */
		protected function stopAllIObjectAnimations():void
		{
			for(var i:int=0,len:int = _IObjects.length; i<len; i++)
			{
				TweenMax.killTweensOf(_IObjects[i],true);
			}
		}
		
		/**
		 * Listener function for key press events
		 */
		protected function onKeyPress(e:KeyboardEvent):void
		{
			var keyCode:int = e.keyCode;
			var isCtrl:Boolean = e.ctrlKey;
			var isShift:Boolean = e.shiftKey;
			var isAlt:Boolean = e.altKey;
			var keyLocation:int = e.keyLocation;
			
			//trace("SCREEN keyCode " + keyCode);
			respondToKeyPress(keyCode, isCtrl, isAlt, isShift, keyLocation);
		}
		
		/**
		 * Perform an action based on the keypress
		 */
		protected function respondToKeyPress(keyCode:int, control:Boolean=false, alt:Boolean=false, shift:Boolean = false, location:int=0):void
		{
			//
		}
		
		/**
		 * Prevent any mouse interactivity
		 */
		protected function disableInteraction():void
		{
			_interactivityEnabled = false;
			_InteractionLayer.mouseChildren = false;
			TweenMax.to(_InteractionLayer, .5, {alpha:.75, ease:Quad.easeOut});
		}
		
		/**
		 * Enable mouse interactivity
		 */
		protected function enableInteraction():void
		{
			_interactivityEnabled = true;
			_InteractionLayer.mouseChildren = true;
			TweenMax.to(_InteractionLayer, .25, {alpha:1, ease:Quad.easeOut});
		}
		
		//---------------------------------------------------------------------
		//
		//	INTERACTIVITY
		//
		//---------------------------------------------------------------------
		
		/**
		 * Enable mouse interaction on the interactive object
		 */
		protected function enableIObject(iobject:*):void 
		{
			iobject.buttonMode = true;
			iobject.mouseChildren = false;
			iobject.addEventListener(MouseEvent.ROLL_OVER, onIObjectOver, false, 0, true);
			iobject.addEventListener(MouseEvent.ROLL_OUT, onIObjectOut, false, 0, true);
			iobject.addEventListener(MouseEvent.MOUSE_DOWN, onIObjectDown, false, 0, true);
			iobject.addEventListener(MouseEvent.MOUSE_UP, onIObjectUp, false, 0, true);
			// for accessibility
			iobject.addEventListener(FocusEvent.FOCUS_IN, onIObjectFocusIn, false, 0, true);
			iobject.addEventListener(FocusEvent.FOCUS_OUT, onIObjectFocusOut, false, 0, true);
		}

		/**
		 * Enable mouse interaction for all intearctive objects
		 */
		protected function enableAllInteractiveObjects():void
		{
			for (var i:int = 0, len:int = numIObjects; i < len; i++)
			{
				enableIObject(_IObjects[i]);
			}
		}

		/**
		 * Interactive object, mouse up event handler
		 * @param	e
		 */
		protected function onIObjectOver(e:MouseEvent):void 
		{
			trace("InteractiveObject OVER " + e.target);
		}
		
		/**
		 * Interactive object, mouse up event handler
		 * @param	e
		 */
		protected function onIObjectOut(e:MouseEvent):void 
		{
			trace("InteractiveObject OUT " + e.target);
		}
		
		/**
		 * Interactive object, mouse up event handler
		 * @param	e
		 */
		protected function onIObjectClick(e:MouseEvent):void
		{
			trace("InteractiveObject CLICK " + e.target);
		}
		
		/**
		 * Interactive object, mouse up event handler
		 * @param	e
		 */
		protected function onIObjectDown(e:MouseEvent):void 
		{
			trace("InteractiveObject DOWN " + e.target);
		}
		
		/**
		 * Interactive object, mouse up event handler
		 * @param	e
		 */
		protected function onIObjectUp(e:MouseEvent):void
		{
			trace("InteractiveObject UP " + e.target);
		}
		
		/**
		 * Interactive object, focus in handler
		 * @param	e
		 */
		protected function onIObjectFocusIn(e:FocusEvent):void
		{
			trace("InteractiveObject Focus In " + e.target);
		}
		
		/**
		 * Interactive object, focus out handler
		 * @param	e
		 */
		protected function onIObjectFocusOut(e:FocusEvent):void
		{
			trace("InteractiveObject Focus Out " + e.target);
		}
		
		/**
		 * Enable mouse interaction on the interactive object
		 */
		protected function disableIObject(iobject:*):void 
		{
			iobject.buttonMode = false;
			iobject.removeEventListener(MouseEvent.ROLL_OVER, onIObjectOver);
			iobject.removeEventListener(MouseEvent.ROLL_OUT, onIObjectOut);
			iobject.removeEventListener(MouseEvent.MOUSE_DOWN, onIObjectDown);
			iobject.removeEventListener(MouseEvent.MOUSE_UP, onIObjectUp);
			iobject.removeEventListener(FocusEvent.FOCUS_IN, onIObjectFocusIn);
			iobject.removeEventListener(FocusEvent.FOCUS_OUT, onIObjectFocusOut);
		}
		
		/**
		 * Disable mouse interaction for all intearctive objects
		 */
		protected function disableAllInteractiveObjects():void
		{
			for (var i:int = 0, len:int = numIObjects; i < len; i++)
			{
				disableIObject(_IObjects[i]);
			}
		}
		
		/**
		 * Disable and remove all interactive objects
		 */
		protected function deleteAllIObjects():void
		{
			disableAllInteractiveObjects();
			for (var i:int = 0, len:int = numIObjects; i < len; i++)
			{
				_IObjectHolder.removeChild(_IObjects[i]);
				_IObjects[i] = null;
			}
			_IObjects = [];
		}
		
		//---------------------------------------------------------------------
		//
		//	DESTROY
		//
		//---------------------------------------------------------------------
		
		/**
		 * Remove listeners and display objects
		 */
		override public function destroy():void
		{
			deleteAllIObjects();
			
			_stageKeyPressNSignal.remove(onKeyPress);
			_stageKeyPressNSignal = undefined;
			
			super.destroy();
		}
		
	}
	
}