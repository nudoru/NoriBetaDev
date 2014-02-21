package com.nudoru.sheet
{
	import flash.display.Sprite;
	import flash.events.*;
	
	public class POButton extends PageObject implements IPageObject {
		
		private var _POObject					:Sprite;
		private var _ImgLoader					:ImageLoader;
		private var _Label						:String;
		private var _ImageName					:String;
		private var _StartFrame					:int;
		private var _PlayMode					:String;
		private var _BorderStyle				:String;
		private var _BorderWidth				:int = 0;
		private var _Shadow						:Boolean = true;
		private var _Reflect					:Boolean = false;		
		
		// these are frame labels in the SWF
		public static const UP_FRAME			:String = "up";
		public static const DOWN_FRAME			:String = "down";
		public static const OVER_FRAME			:String = "over";
		public static const DISABLED_FRAME		:String = "disabled";

		public static const POB_CLICK			:String = "pob_click";
		public static const POB_ROLLOVER		:String = "pob_rollover";
		public static const POB_ROLLOUT			:String = "pob_rollout";
		public static const POB_PRESS			:String = "pob_press";
		public static const POB_RELEASE			:String = "pob_release";
		
		public function get isSWF():Boolean { 
			if(_ImageName.toLowerCase().indexOf(".swf") > 0) return true;
			return false;
		}
		
		public function POButton(p:Sheet, t:Sprite, x:XMLList):void {
			super(p, t, x);
			parseButtonData();
			render();
		}
		
		public override function getObject():* { return _POObject; }
		
		public override function render():void {
			_Status = STATUS_INIT;
			createContainers(_TargetSprite);
			createGraphic();
			drawBoxes();
			applyDisplayProperties();
		}
		
		override protected function drawBoxes(b:Boolean=false):void {
			if (_HasEvents) {
				//
			} else {
				drawRect(_BoundingRect,_ObjContainer.width,_ObjContainer.height,0xff0000,0xffcccc,0);
				if(b) _BoundingRect.alpha = .2;
			}
		}
		
		private function onButtonOver(e:Event):void {
			dispatchEvent(new POEvent(POEvent.PO_ROLLOVER, true, false, _ID));
		}
		
		private function onButtonOut(e:Event):void {
			dispatchEvent(new POEvent(POEvent.PO_ROLLOUT, true, false, _ID));
		}
		
		private function onButtonDown(e:Event):void {
			dispatchEvent(new POEvent(POEvent.PO_DOWN, true, false, _ID));
		}
		
		private function onButtonClick(e:Event):void {
			dispatchEvent(new POEvent(POEvent.PO_CLICK, true, false, _ID));
			dispatchEvent(new POEvent(POEvent.PO_RELEASE, true, false, _ID));
		}
		
		public function gotoFrameAndStop(f:*, t:String = ""):void {
			if (t.indexOf("@") > 1) t = t.split("@")[1];
				else t = undefined;
			try {
				if(isSWF) _ImgLoader.imageAdvanceToFrame(f,false,t);
			} catch(e:*) {}
		}

		private function createGraphic():void {
			var i:Sprite = new Sprite();
			_ImgLoader = new ImageLoader(_ImageName, i, {x:0,
														 y:0,
														 width:_Width,
														 height:_Height,
														 border:_BorderWidth,
														 borderstyle:_BorderStyle,
														 shadow:_Shadow,
														 reflect:_Reflect } );
			_ImgLoader.addEventListener(ImageLoader.LOADED,onGraphicLoaded);
			_POObject = i;
			_ObjContainer.addChild(_POObject);
		}
		
		private function onGraphicLoaded(e:Event):void {
			loaded = true;
			//Object(_ImgLoader.content).label_txt.text = _Label;
			_ImgLoader.content.addEventListener(POButton.POB_CLICK, onButtonClick);
			_ImgLoader.content.addEventListener(POButton.POB_RELEASE, onButtonClick);
			_ImgLoader.content.addEventListener(POButton.POB_ROLLOVER, onButtonOver);
			_ImgLoader.content.addEventListener(POButton.POB_ROLLOUT, onButtonOut);
			_ImgLoader.content.addEventListener(POButton.POB_PRESS, onButtonDown);
		}
		
		private function parseButtonData():void {
			_Label = _XMLData.label;
			_ImageName = _XMLData.url;
			_StartFrame = int(_XMLData.url.@startframe);
			_PlayMode = _XMLData.url.@playmode;
			_BorderStyle = _XMLData.borderstyle;
			_BorderWidth = int(_XMLData.borderwidth);
			_Shadow = isBool(_XMLData.shadow);
			_Reflect = isBool(_XMLData.reflect);
		}

		public override function destroy():void {
			if (loaded) {
				_ImgLoader.content.removeEventListener(POButton.POB_CLICK, onButtonClick);
				_ImgLoader.content.removeEventListener(POButton.POB_RELEASE, onButtonClick);
				_ImgLoader.content.removeEventListener(POButton.POB_ROLLOVER, onButtonOver);
				_ImgLoader.content.removeEventListener(POButton.POB_ROLLOUT, onButtonOut);
				_ImgLoader.content.removeEventListener(POButton.POB_PRESS, onButtonDown);
			}
			_ImgLoader.destroy();
			removeListeners();
			_ObjContainer.removeChild(_POObject);
			_POObject = null;
		}
		
	}
}