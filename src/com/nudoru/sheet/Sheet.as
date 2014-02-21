package com.nudoru.sheet {
	
	import com.nudoru.utilities.GUID;
	import flash.display.Sprite;
	import flash.events.*;
	
	public class Sheet extends Sprite {
		
		private var _Started					:Boolean;
		private var _Initialized				:Boolean;
		private var _Unloading					:Boolean;
		private var _UnloadingCntr				:int;
		private var _id							:String;
		
		private var _XMLData					:XML;
		private var _EventManager				:POEventManager;
		
		private var _PageObjects				:Array;

		public static const RENDERED			:String = "rendered";
		public static const PARSING_ERROR		:String = "parsing_error";
		public static const STOPPED				:String = "stopped";

		public function get id():String { return _id; };
		
		public function get HasPOMouseEvents():Boolean { return _EventManager.hasMouseEvents; }
		public function get HasPOTimerEvents():Boolean { return _EventManager.hasTimedEvents; }

		public function Sheet():void {
			_Initialized = false;
		}
		
		public function initialize(x:XML):void {
			_Initialized = true;
			_XMLData = x;
			_id = _XMLData.@id;
			if (!_id) _id = GUID.getGUID();

			_EventManager = new POEventManager(this);
			addChild(_EventManager);
			
			_PageObjects = new Array();
		}
		
		public function render():void {
			parseSheetXML(_XMLData);
		}
		
		public function start():void {
			if (_Started || !_Initialized) return;
			_Started = true;
			_EventManager.start();
			beginPOAnimations();
		}
		
		public function stop():void {
			//trace("~sheet: stop");
			if (!_Initialized) {
				dispatchEvent(new Event(Sheet.STOPPED));
				return;
			}
			_Unloading = true;
			_UnloadingCntr = 0;
			_Started = false;
			_EventManager.stop();
			if (anyPOTransitionOutAnims()) {
				//trace("   playing trans out");
				beginPOOutAnimations();
			} else {
				//trace("   no trans out");
				dispatchEvent(new Event(Sheet.STOPPED));
			}
		}
		
		private function onPOOutAnimComplete(e:Event):void {
			if (!_Unloading) return;
			//_UnloadingCntr++;
			//trace(_UnloadingCntr +" of " + _PageObjects.length);
			if (++_UnloadingCntr == _PageObjects.length) {
				//trace("~sheet: all outs complete");
				dispatchEvent(new Event(Sheet.STOPPED));
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// PO Loaded

		private function onPOLoaded(e:Event):void {
			checkPOsLoaded();
		}
		
		public function checkSheetLoaded():void {
			checkPOsLoaded();
		}
		
		private function checkPOsLoaded():void {
			var c:int = 0;
			var len:int = _PageObjects.length;
			for (var i:int = 0; i < len; i++) {
				if (_PageObjects[i].loaded) c++;
			}
			if (c == len || !len) {
				clearPOLoadedEvents();
				dispatchEvent(new Event(Sheet.RENDERED));
			}
		}
		
		private function clearPOLoadedEvents():void {
			var len:int = _PageObjects.length;
			for (var i:int = 0; i < len; i++) {
				_PageObjects[i].removeEventListener(PageObject.LOADED, onPOLoaded);
			}
		}
		
		public function beginPOAnimations():void {
			var len:int = _PageObjects.length;
			if (!len) return;
			for (var i:int = 0; i < len; i++) {
				//trace("begin: " + _PageObjects[i]);
				_PageObjects[i].beginAnimations();
			}
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// transition out animations on page unload
		
		public function anyPOTransitionOutAnims():Boolean {
			var len:int = _PageObjects.length;
			for (var i:int = 0; i < len; i++) {
				if (_PageObjects[i].hasTransitionOut) return true;
			}
			return false;
		}
		
		public function beginPOOutAnimations():void {
			var len:int = _PageObjects.length;
			for (var i:int = 0; i < len; i++) {
				//trace("~out: " + _PageObjects[i]);
				_PageObjects[i].addEventListener(POEvent.PO_TRANSITIONOUT_COMPLETE, onPOOutAnimComplete);
				_PageObjects[i].beginOutAnimations();
			}
			return;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// for event lists
		
		public function addEventList(e:XMLList, t:*):void {
			//trace("Sheet, reg events: "+t.id);
			_EventManager.addEventList(e, t);
			// for mouse events
			t.addEventListener(POEvent.PO_ROLLOVER, onPORollOver);
			t.addEventListener(POEvent.PO_ROLLOUT, onPORollOut);
			t.addEventListener(POEvent.PO_CLICK, onPOClick);
			t.addEventListener(POEvent.PO_RELEASE, onPORelease);
			// for playback events
			t.addEventListener(POEvent.PO_START, onPOPBStart);
			t.addEventListener(POEvent.PO_PLAY, onPOPBPlay);
			t.addEventListener(POEvent.PO_PAUSE, onPOPBPause);
			t.addEventListener(POEvent.PO_STOP, onPOPBStop);
			t.addEventListener(POEvent.PO_FINISH, onPOPBFinish);
		}
		
		private function onPORollOver(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_ROLLOVER, e.targetID);
		}
		private function onPORollOut(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_ROLLOUT, e.targetID);
		}
		private function onPOClick(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_CLICK, e.targetID);
		}
		private function onPORelease(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_RELEASE, e.targetID);
		}
		private function onPOPBStart(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_START, e.targetID);
		}
		private function onPOPBPlay(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_PLAY, e.targetID);
		}
		private function onPOPBPause(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_PAUSE, e.targetID);
		}
		private function onPOPBStop(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_STOP, e.targetID);
		}
		private function onPOPBFinish(e:POEvent):void {
			_EventManager.performEvent(POEvent.PO_FINISH, e.targetID);
		}
		
		// should only be called by POEventManager
		public function getPOByID(id:String):* {
			var len:int = _PageObjects.length;
			for(var i:int=0; i<len; i++) {
				if(_PageObjects[i].id == id) return _PageObjects[i];
			}
			trace("Sheet, PO ID not found: "+id);
			return undefined;
		}
		
		public function getPOSpriteByID(id:String):Sprite {
			return getPOByID(id).container;
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// parsing
		
		private function parseSheetXML(d:XML):void {
			//trace("parse: " + d);
			for (var i:int = 0, len:int = d.children().length(); i < len; i++) {
				var o:IPageObject = POFactory.createPO(d.children()[i].localName(), this, this, XMLList(d.children()[i]));
				if (o) {
					_PageObjects.push(o);
					_PageObjects[_PageObjects.length - 1].addEventListener(PageObject.LOADED, onPOLoaded);
				}
			}
			// checks to see if all POs are loaded
			checkPOsLoaded();
		}
		
		//----------------------------------------------------------------------------------------------------------------------------------
		// other
		
		public function destroy():void {
			//trace("destroy sheet ...");
			if (!_Initialized) return;

			if(_Started) stop();
			var len:int = _PageObjects.length;
			for (var i:int = 0; i < len; i++) {
				if(_PageObjects[i].hasEvents) {
					_PageObjects[i].removeEventListener(POEvent.PO_ROLLOVER, onPORollOver);
					_PageObjects[i].removeEventListener(POEvent.PO_ROLLOUT, onPORollOut);
					_PageObjects[i].removeEventListener(POEvent.PO_CLICK, onPOClick);
					_PageObjects[i].removeEventListener(POEvent.PO_RELEASE, onPORelease);
					_PageObjects[i].removeEventListener(POEvent.PO_START, onPOPBStart);
					_PageObjects[i].removeEventListener(POEvent.PO_PLAY, onPOPBPlay);
					_PageObjects[i].removeEventListener(POEvent.PO_PAUSE, onPOPBPause);
					_PageObjects[i].removeEventListener(POEvent.PO_STOP, onPOPBStop);
					_PageObjects[i].removeEventListener(POEvent.PO_FINISH, onPOPBFinish);
				}
				_PageObjects[i].removeEventListener(PageObject.LOADED, onPOLoaded);
				_PageObjects[i].destroy();
				_PageObjects[i].cleanUp();
			}
			_PageObjects = new Array();
			
			removeChild(_EventManager);
			_EventManager.destroy();
			
			_XMLData = null;
			_EventManager = null;
		}
		
	}
	
}