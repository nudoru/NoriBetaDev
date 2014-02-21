/*
Page Object
4.2.08
*/

package com.nudoru.sheet {
	
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	import com.nudoru.visual.BMUtils;
	import com.nudoru.visual.drawing.GradBox;
	import com.nudoru.visual.drawing.RoundGradBox;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.*;
	
	
	public class PageObject extends Sprite implements IPageObject {
		
		protected var _TargetSprite		:Sprite;
		protected var _XMLData			:XMLList;
		protected var _Container		:Sprite;
		protected var _ObjContainer		:Sprite;
		protected var _BoundingRect		:Sprite;
		protected var _HiLightRect		:Sprite;
		
		protected var _SheetRef			:Sheet;
		
		protected var _ID				:String;
		protected var _Name				:String;
		protected var _Type				:String;
		protected var _Locked			:Boolean = true;
		protected var _Draggable		:Boolean = false;
		protected var _X				:int;
		protected var _Y				:int;
		protected var _Width			:int;
		protected var _Height			:int;
		protected var _ScaleX			:Number = 100;
		protected var _ScaleY			:Number = 100;
		protected var _Alpha			:Number = 100;
		protected var _Rotation			:int = 0;
		protected var _BlendMode		:String = "normal";
		protected var _Filters			:Array;	
		protected var _Colors			:Array;
		protected var _StartMode		:String = "normal";
		protected var _ShowBoundingRect	:Boolean;
		protected var _Events			:Array;
		protected var _Status			:int;
		protected var _HasEvents		:Boolean = false;
		protected var _IsMousePressed	:Boolean = false;
		protected var _Loaded			:Boolean;
		
		protected var _TransitionIn		:Transition;
		protected var _TransitionInEff	:String = "";
		protected var _TransitionInMode	:String = "play";
		protected var _TransitionInDly	:Number;
		
		protected var _TransitionOut	:Transition;
		protected var _TransitionOutEff	:String = "";
		protected var _TransitionOutMode:String = "play";
		protected var _TransitionOutDly	:Number;

		private static var _Index		:int;
		
		public static const STATUS_UNINIT	:int = 0;
		public static const STATUS_INIT		:int = 1;
		
		public static const LOADED			:String = "loaded";
		
		public function get id():String { return _ID; }
		public function get type():String { return _Type; }
		public function get loaded():Boolean { return _Loaded; }
		public function set loaded(l:Boolean):void { 
				_Loaded = l;
				//trace(_ID+" loaded: "+_Loaded)
				if(_Loaded) dispatchEvent(new Event(PageObject.LOADED));
		}
		public function get hasEvents():Boolean { return _HasEvents; }
		public function get hasMouseEvents():Boolean { return _SheetRef.HasPOMouseEvents; }
		public function get hasTimerEvents():Boolean { return _SheetRef.HasPOTimerEvents; }
		
		public function get hasTransitionIn():Boolean {
			if (_TransitionInEff.length) return true;
			return false;
		}
		public function get hasTransitionOut():Boolean {
			if (_TransitionOutEff.length) return true;
			return false;
		}
		
		public function get container():Sprite { return _Container; }
		public function get boundingRect():Sprite { return _BoundingRect; }
		public function get hiLightRect():Sprite { return _HiLightRect; }
		
		public function PageObject(p:Sheet, t:Sprite, x:XMLList):void {
			_Index++;
			
			_Filters = [];
			_Events = [];
			_Colors = [];
			_ShowBoundingRect = false;
			_SheetRef = p;
			_TargetSprite = t;
			_XMLData = x;
			_Status = STATUS_UNINIT;
			loaded = false;
			parseCommonData();
		}
		
		
		// this is a template, subclasses must override
		public function getObject():* {
			//
		}
		
		// this is a template, subclasses must override
		public function command(c:String):void {
			// 
		}
		
		private function parseCommonData():void {
			_Filters = new Array();
			_Events = new Array();
			
			_ID = _XMLData.@id;
			_Name = _XMLData.@name;
			_Type = String(_XMLData.localName());
			_X = int(String(_XMLData.position).split(",")[0]);
			_Y = int(String(_XMLData.position).split(",")[1]);
			_Width = int(String(_XMLData.size).split(",")[0]);
			_Height = int(String(_XMLData.size).split(",")[1]);
			if(_XMLData.scale.length()) _ScaleX = int(String(_XMLData.scale).split(",")[0]);
			if(_XMLData.scale.length()) _ScaleY = int(String(_XMLData.scale).split(",")[1]);
			if(_XMLData.alpha.length()) _Alpha = int(_XMLData.alpha);
			if(_XMLData.rotation.length()) _Rotation = int(_XMLData.rotation);
			if (_XMLData.blendmode.length()) _BlendMode = _XMLData.blendmode;
			if (_XMLData.colors.length()) _Colors = _XMLData.colors.split(",");
				else _Colors = [0x999999, 0xEEEEEE, 0xEAEAEA];
			if(_XMLData.start.length()) _StartMode = _XMLData.start.@mode;
			if(_XMLData.transitionin.length()) {
				_TransitionInEff = _XMLData.transitionin.@effect;
				_TransitionInMode = _XMLData.transitionin.@mode;
				_TransitionInDly = _XMLData.transitionin.@delay;
			}
			if(_XMLData.transitionout.length()) {
				_TransitionOutEff = _XMLData.transitionout.@effect;
				_TransitionOutMode = _XMLData.transitionout.@mode;
				_TransitionOutDly = _XMLData.transitionout.@delay;
			}
			if(_XMLData.eventlist.length()) {
				_HasEvents = true;
				_SheetRef.addEventList(_XMLData.eventlist, this);
			}
			if (_XMLData.bmfilter.length()) {
				var len:int = _XMLData.bmfilter.length();
				for (var i:int = 0; i < len; i++) {
					_Filters.push(createFilterObject(XMLList(_XMLData.bmfilter[i])));
				}
			}
			
			//_ShowBoundingRect = true;
			//error check and set defaults
			if(_Alpha) _Alpha *= .01;
			if(!_Width) _Width = 100;
			if(!_Height) _Height = 100;
			if(_ScaleX) _ScaleX *= .01;
			if(_ScaleY) _ScaleY *= .01;
			//trace("new object of type: "+_Type+", at: x"+_X+", y"+_Y);
		}
		
		protected function createFilterObject(d:XMLList):Object {
			var o:Object = new Object();
			o.type = d.@type;
			o.color = Number(d.color);
			o.alpha = Number(d.alpha);
			o.blur = Number(d.blur);
			o.blurx = Number(d.blurx);
			o.blury = Number(d.blury);
			o.strength = Number(d.strength);
			o.angle = Number(d.angle);
			o.distance = Number(d.distance);
			return o;
		}
		
		protected function createContainers(target:Sprite):void {
			_Container = new Sprite();
			_Container.name = "pageobject"+_Index+"_mc";
			_BoundingRect = new Sprite();
			_BoundingRect.name = "pageobjectbounding_mc";
			_ObjContainer = new Sprite();
			_ObjContainer.name = "pageobjectcontainer_mc";
			_HiLightRect = new Sprite();
			_HiLightRect.name = "pageobjecthilight_mc";
			_Container.x = _X;
			_Container.y = _Y;
			_Container.addChild(_BoundingRect);
			_Container.addChild(_ObjContainer);
			_Container.addChild(_HiLightRect);
			target.addChild(_Container);
			if(_TransitionInEff.length) _Container.visible = false;
		}
		
		// this is a template, subclasses must override
		public function render():void {
			//
		}
		
		// so that PO player SWFs can set loaded via the interface
		public function setLoaded():void {
			loaded = true;
		}
		
		protected function applyDisplayProperties():void {
			_Container.scaleX = _ScaleX;
			_Container.scaleY = _ScaleY;
			_Container.alpha = _Alpha;
			_Container.rotation = _Rotation;
			_Container.blendMode = _BlendMode;		// should probably use constants here, but that would require an if block
			if (_Filters.length) applyBMFilters();
			if(_StartMode == "hide") hide();
			if(_TransitionOutEff.length) {
				_TransitionOut = new Transition(_Container,_TransitionOutEff,_TransitionOutDly,0);
			}
			if(_TransitionInEff.length) {
				_TransitionIn = new Transition(_Container,_TransitionInEff,_TransitionInDly,1);
			}
		}
		
		protected function applyBMFilters():void {
			for (var i:int = 0; i < _Filters.length; i++) {
				if (_Filters[i].type == "blur") BMUtils.applyBlurFilter(_Container, _Filters[i].blurx, _Filters[i].blury);
				if (_Filters[i].type == "glow") BMUtils.applyGlowFilter(_Container, _Filters[i].color, _Filters[i].alpha, _Filters[i].blur, _Filters[i].strength);
				if (_Filters[i].type == "shadow") BMUtils.applyDropShadowFilter(_Container, _Filters[i].distance, _Filters[i].angle, _Filters[i].color, _Filters[i].alpha, _Filters[i].blur, _Filters[i].strength);
				if (_Filters[i].type == "desaturate") BMUtils.desaturate(_Container);
				if (_Filters[i].type == "saturate") BMUtils.saturate(_Container);
			}
		}
		
		// maybe overridden by subclasses, like POGraphic
		public function beginAnimations():void {
			if(_TransitionInEff.length) {
				if (_TransitionInMode == "play") playTransitionIn();
			}
		}
		
		public function beginOutAnimations():void {
			if(_TransitionOutEff.length) {
				playTransitionOut();
			} else {
				dispatchEvent(new POEvent(POEvent.PO_TRANSITIONOUT_COMPLETE, true, false, _ID));
			}
		}
		
		public function toggleVis():void {
			if(_Container.visible) {
				_Container.visible = false;
				return;
			}
			_Container.visible = true;
		}
		
		public function hide():void {
			_Container.visible = false;
		}
		
		public function show():void {
			_Container.visible = true;
		}
		
		public function playTransitionIn():void {
			//make sure these events are removed!
			//_TransitionIn.addEventListener(Transition.TRANSITION_START, onTransitionInStart);
			//_TransitionIn.addEventListener(Transition.TRANSITION_COMPLETE, onTransitionInComplete);
			_TransitionIn.play();
		}
		
		public function onTransitionInStart(e:Event):void {
			_TransitionIn.removeEventListener(Transition.TRANSITION_START, onTransitionInStart);
			dispatchEvent(new POEvent(POEvent.PO_TRANSITIONIN_START, true, false, _ID));
		}
		
		public function onTransitionInComplete(e:Event):void {
			_TransitionIn.removeEventListener(Transition.TRANSITION_COMPLETE, onTransitionInComplete);
			dispatchEvent(new POEvent(POEvent.PO_TRANSITIONIN_COMPLETE, true, false, _ID));
		}
		
		public function playTransitionOut():void {
			trace("playing transition out");
			_TransitionOut.addEventListener(Transition.TRANSITION_START, onTransitionOutStart);
			_TransitionOut.addEventListener(Transition.TRANSITION_COMPLETE, onTransitionOutComplete);
			_TransitionOut.play();
		}
		
		public function onTransitionOutStart(e:Event):void {
			_TransitionOut.removeEventListener(Transition.TRANSITION_START, onTransitionOutStart);
			dispatchEvent(new POEvent(POEvent.PO_TRANSITIONOUT_START, true, false, _ID));
		}
		
		public function onTransitionOutComplete(e:Event):void {
			trace("~pageobject: transition out complete");
			_TransitionOut.removeEventListener(Transition.TRANSITION_COMPLETE, onTransitionOutComplete);
			dispatchEvent(new POEvent(POEvent.PO_TRANSITIONOUT_COMPLETE, true, false, _ID));
		}

		protected function drawBoxes(b:Boolean = false):void {
			if (!hasEvents) return;
			//drawRect(_BoundingRect,_ObjContainer.width,_ObjContainer.height,0xff0000,0xffcccc,0);
			if(b) _BoundingRect.alpha = .2;
			if (hasMouseEvents) {
				// for button objects, all of this is in the class
				drawRect(_HiLightRect,_ObjContainer.width,_ObjContainer.height,SheetSettings.instance.themeHiColor,SheetSettings.instance.themeHiColor,1);
				_HiLightRect.alpha = 0;
				_HiLightRect.blendMode = BlendMode.MULTIPLY;
				_HiLightRect.addEventListener(MouseEvent.ROLL_OVER, onHLOver);
				_HiLightRect.addEventListener(MouseEvent.ROLL_OUT, onHLOut);
				_HiLightRect.addEventListener(MouseEvent.MOUSE_DOWN, onHLDown);
				_HiLightRect.addEventListener(MouseEvent.CLICK, onHLClick);
				_HiLightRect.buttonMode = true;
				_HiLightRect.mouseChildren = false;
			}
		}
		
		private function onHLOver(e:MouseEvent):void {
			TweenLite.to(_HiLightRect, .25, {alpha:.25, ease:Quad.easeOut});
			dispatchEvent(new POEvent(POEvent.PO_ROLLOVER, true, false, _ID));
		}
		
		private function onHLOut(e:MouseEvent):void {
			TweenLite.to(_HiLightRect, .5, {alpha:0, ease:Quad.easeOut});
			dispatchEvent(new POEvent(POEvent.PO_ROLLOUT, true, false, _ID));
		}
		
		private function onHLDown(e:MouseEvent):void {
			TweenLite.to(_HiLightRect, .1, {alpha:.5, ease:Quad.easeOut});
			dispatchEvent(new POEvent(POEvent.PO_DOWN, true, false, _ID));
		}
		
		private function onHLClick(e:MouseEvent):void {
			TweenLite.to(_HiLightRect, .25, { alpha:0, delay:.25, ease:Quad.easeOut } );
			dispatchEvent(new POEvent(POEvent.PO_CLICK, true, false, _ID));
			dispatchEvent(new POEvent(POEvent.PO_RELEASE, true, false, _ID));
		}
		
		protected function isBool(s:String):Boolean {
			if(s.toLowerCase().indexOf("t") == 0) return true;
			return false;
		}

		// this is a template, subclasses must override
		// these functions should call removeListeners
		// cleanup is called by the Sheet
		public function destroy():void {
			//
		}

		protected function removeListeners():void {
			if(hasMouseEvents) {
				_HiLightRect.removeEventListener(MouseEvent.ROLL_OVER, onHLOver);
				_HiLightRect.removeEventListener(MouseEvent.ROLL_OUT, onHLOut);
				_HiLightRect.removeEventListener(MouseEvent.MOUSE_DOWN, onHLDown);
				_HiLightRect.removeEventListener(MouseEvent.CLICK, onHLClick);
			}
		}
		
		public function cleanUp():void {
			_TransitionIn = null;
			_TransitionOut = null;
			
			_Container.removeChild(_BoundingRect);
			_Container.removeChild(_ObjContainer);
			_Container.removeChild(_HiLightRect);
			_TargetSprite.removeChild(_Container);
			_Container = null;
			_TargetSprite = null;
		}
		
		protected function drawRect(target:Sprite, w:int, h:int, line:int, fill:int, alpha:Number):void {
			if(SheetSettings.instance.themeHiStyle == "gradient") {
				//trace("drawing hi: " + fill.toString(16));
				var a:GradBox = new GradBox(target, 0, 0, w, h, false, { bc:fill } );
				target.alpha = 0;
			} else if(SheetSettings.instance.themeHiStyle.indexOf("rounded") == 0) {
				//trace("drawing hi: " + fill.toString(16));
				var b:RoundGradBox = new RoundGradBox(target, 0, 0, w, h, false, SheetSettings.instance.themeHiStyle.split(":")[1], { expand:true, bc:fill } );
				target.alpha = 0;
			} else {
				target.graphics.lineStyle(0,line,alpha);
				target.graphics.beginFill(fill,alpha);
				target.graphics.drawRect(0,0,w,h);
				target.graphics.endFill();
			}
		}
	}
}