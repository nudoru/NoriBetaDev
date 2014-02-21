package com.nudoru.sheet {

	import flash.display.Sprite;
	import flash.events.*;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.plugins.MotionBlurPlugin;
	import com.greensock.plugins.ColorMatrixFilterPlugin;
	
	public class Transition extends Sprite {

		private var _Transitions			:Array;
		
		private var _TargetSprite			:Sprite;
		private var _TransitionIdx			:int;
		private var _Delay					:Number;
		private var _OrigionalProps			:Object;
		private var _DestinationProps		:Object;
		private var _Direction				:int = 1;	//1 = transition in, 0 = out
		
		private var _UsesBlurFilter			:Boolean = false;
		private var _UsesColorFilter		:Boolean = false;
		
		// constants for events
		public static const TRANSITION_START		:String = "transitionstart";
		public static const TRANSITION_COMPLETE		:String = "transitioncomplete";
		
		public function Transition(t:Sprite, e:String, d:Number, r:int = 1):void {
			TweenPlugin.activate([MotionBlurPlugin]);
			TweenPlugin.activate([ColorMatrixFilterPlugin]); 
			
			_TargetSprite = t;
			_Delay = d;
			_Direction = r;
			setOrigionalProps();
			setDestinationPropsIn();
			defineTransitions();
			_TransitionIdx = getTransIdxByName(e);
		}
	
		private function defineTransitions():void {
			_Transitions = new Array();
			//createTransObject(n:String, xoffs:Number, yoffs:Number, alphastrt:Number, rotstrt:Number, xscalestrt:Number, yscalestrt:Number, xblurstrt:Number, yblurstrt:Number, britenessstrt:Number, dur:Number, twn:String, mb:Boolean = false;);
			createTransObject("fade_in", 0, 0, 0, -1, -1, -1, 0, 0, 0, 1, Quad.easeOut);
			createTransObject("bright_in", 0, 0, -1, -1, -1, -1, 0, 0, 255, .5, Quad.easeOut);
			createTransObject("bright_in_flicker", 0, 0, -1, -1, -1, -1, 0, 0, 255, .5, Elastic.easeOut);
			createTransObject("slide_from_left", -600, 0, 0, -1, -1, -1, 50, 0, 0, 2, Back.easeOut, true);
			createTransObject("slide_from_right", 600, 0, 0, -1, -1, -1, 50, 0, 0, 2, Back.easeOut, true);
			createTransObject("drop_from_top", 0, -700, 0, -1, -1, -1, 0, 100, 0, 2, Bounce.easeOut, true);
			createTransObject("fall_off", 200, 600, 0, 90, -1, -1, 0, 0, 0, 3, Expo.easeIn, true);
			createTransObject("zoom_out", -100, -100, 0, -1, 4, 4, 50, 50, 0, 2, Expo.easeOut);
			createTransObject("subtle_left", -20, 0, 0, -1, -1, -1, 10, 0, 0, 1, Quad.easeOut);
			createTransObject("subtle_right", 20, 0, 0, -1, -1, -1, 10, 0, 0, 1, Quad.easeOut);
			createTransObject("subtle_top", 0, -20, 0, -1, -1, -1, 0, 10, 0, 1, Quad.easeOut);
			createTransObject("subtle_bottom", 0, 20, 0, -1, -1, -1, 0, 10, 0, 1, Quad.easeOut);
		}
		
		public function play():void {
			//trace("transition d: "+_Direction+", "+_TransitionIdx);
			killExistingTweens();
			if(_Direction == 0) {
				setDestinationPropsOut();
			} else {
				applyStartingProperties();
				_TargetSprite.visible = true;
			}
			
			if (_UsesBlurFilter) {
				doBlurTween();
			} else if (_UsesColorFilter) {
				doColorTween();
			} else {
				doNormalTween();
			}
			
		}
		
		private function killExistingTweens():void {
			TweenMax.killDelayedCallsTo(_TargetSprite);
			TweenMax.killTweensOf(_TargetSprite);
		}
		
		//http://blog.greensock.com/tweenfilterliteas3/
		private function doBlurTween():void {
			//trace(_DestinationProps.x+", "+_DestinationProps.y+", "+_DestinationProps.alpha+", "+_DestinationProps.rotation+", "+_DestinationProps.scaleX+", "+_DestinationProps.scaleY)
			TweenMax.to(_TargetSprite, _Transitions[_TransitionIdx].durration, 
											{delay:_Delay, 
											ease: _Transitions[_TransitionIdx].tween,
											x:_DestinationProps.x,
											y:_DestinationProps.y,
											alpha:_DestinationProps.alpha,
											rotation:_DestinationProps.rotation,
											scaleX:_DestinationProps.scaleX,
											scaleY:_DestinationProps.scaleY,
											blurFilter: { blurX:0, blurY:0 },
											motionBlur: _Transitions[_TransitionIdx].motionblur,
											onStart:onTweenStart,
											onComplete:onTweenComplete
											});
		}
		
		private function doColorTween():void {
			//trace(_DestinationProps.x+", "+_DestinationProps.y+", "+_DestinationProps.alpha+", "+_DestinationProps.rotation+", "+_DestinationProps.scaleX+", "+_DestinationProps.scaleY)
			TweenMax.to(_TargetSprite, _Transitions[_TransitionIdx].durration, 
											{delay:_Delay, 
											ease: _Transitions[_TransitionIdx].tween,
											x:_DestinationProps.x,
											y:_DestinationProps.y,
											alpha:_DestinationProps.alpha,
											rotation:_DestinationProps.rotation,
											scaleX:_DestinationProps.scaleX,
											scaleY:_DestinationProps.scaleY,
											colorMatrixFilter:{brightness:1},
											motionBlur: _Transitions[_TransitionIdx].motionblur,
											onStart:onTweenStart,
											onComplete:onTweenComplete
											});
		}
		
		private function doNormalTween():void {
			//trace("tween normal");
			//trace(_DestinationProps.x+", "+_DestinationProps.y+", "+_DestinationProps.alpha+", "+_DestinationProps.rotation+", "+_DestinationProps.scaleX+", "+_DestinationProps.scaleY)
			TweenMax.to(_TargetSprite, _Transitions[_TransitionIdx].durration, 
											{delay:_Delay, 
											ease: _Transitions[_TransitionIdx].tween,
											x:_DestinationProps.x,
											y:_DestinationProps.y,
											alpha:_DestinationProps.alpha,
											rotation:_DestinationProps.rotation,
											scaleX:_DestinationProps.scaleX,
											scaleY:_DestinationProps.scaleY,
											motionBlur: _Transitions[_TransitionIdx].motionblur,
											onStart:onTweenStart,
											onComplete:onTweenComplete
											});
		}
		
		private function onTweenStart():void {
			dispatchEvent(new Event(Transition.TRANSITION_START));
		}
	
		private function onTweenComplete():void {
			if(_Direction == 0) _TargetSprite.visible = false;
			dispatchEvent(new Event(Transition.TRANSITION_COMPLETE));
		}
	
		private function applyStartingProperties():void {
			_TargetSprite.x = _OrigionalProps.x + _Transitions[_TransitionIdx].xoffset;
			_TargetSprite.y = _OrigionalProps.y + _Transitions[_TransitionIdx].yoffset;
			_TargetSprite.alpha = _Transitions[_TransitionIdx].alphastart;
			_TargetSprite.rotation = _Transitions[_TransitionIdx].rotstart;
			_TargetSprite.scaleX = _Transitions[_TransitionIdx].xscalestart;
			_TargetSprite.scaleY = _Transitions[_TransitionIdx].yscalestart;
			applyBlurFilter(_Transitions[_TransitionIdx].blurxstart, _Transitions[_TransitionIdx].blurystart);
			applyColorFilter(_Transitions[_TransitionIdx].brightstart);
		}
	
		private function applyBlurFilter(x:int,y:int):void {
			if (x == 0 && y == 0) return;
			_UsesBlurFilter = true;
			var blur:BlurFilter = new BlurFilter();
			blur.blurX = x;
			blur.blurY = y;
			blur.quality = BitmapFilterQuality.MEDIUM;
			_TargetSprite.filters = [blur];
		}
	
		private function applyColorFilter(b:int):void {
			if (!b) return;
			//trace("applying color "+b);
			_UsesColorFilter = true;
			var matrix:Array = new Array();
            matrix = matrix.concat([1, 0, 0, 0, b]); // red
            matrix = matrix.concat([0, 1, 0, 0, b]); // green
            matrix = matrix.concat([0, 0, 1, 0, b]); // blue
            matrix = matrix.concat([0, 0, 0, 1, 0]); // alpha
			var filter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			_TargetSprite.filters = [filter];
		}
		
		private function setOrigionalProps():void {
			_OrigionalProps = new Object();
			_OrigionalProps.x = _TargetSprite.x;
			_OrigionalProps.y = _TargetSprite.y;
			_OrigionalProps.alpha = _TargetSprite.alpha;
			_OrigionalProps.rotation = _TargetSprite.rotation;
			_OrigionalProps.scaleX =_TargetSprite.scaleX;
			_OrigionalProps.scaleY = _TargetSprite.scaleY;
		}
	
		private function setDestinationPropsIn():void {
			_DestinationProps = new Object();
			_DestinationProps.x = _TargetSprite.x;
			_DestinationProps.y = _TargetSprite.y;
			_DestinationProps.alpha = _TargetSprite.alpha;
			_DestinationProps.rotation = _TargetSprite.rotation;
			_DestinationProps.scaleX =_TargetSprite.scaleX;
			_DestinationProps.scaleY = _TargetSprite.scaleY;
		}
	
		private function setDestinationPropsOut():void {
			var dx:int = _OrigionalProps.x;
			var dy:int = _OrigionalProps.y;
			_DestinationProps = new Object();
			_DestinationProps.x = dx + _Transitions[_TransitionIdx].xoffset;
			_DestinationProps.y = dy + _Transitions[_TransitionIdx].yoffset;
			_DestinationProps.alpha = _Transitions[_TransitionIdx].alphastart;
			_DestinationProps.rotation = _Transitions[_TransitionIdx].rotstart;
			_DestinationProps.scaleX = _Transitions[_TransitionIdx].xscalestart;
			_DestinationProps.scaleY = _Transitions[_TransitionIdx].yscalestart;
		}
	
		private function getTransIdxByName(n:String):int {
			for(var i:int=0; i<_Transitions.length; i++) {
				if(_Transitions[i].name == n) return i;
			}
			return 0;
		}
		
		private function getTransObjByName(n:String):Object {
			for(var i:int=0; i<_Transitions.length; i++) {
				if(_Transitions[i].name == n) return _Transitions[i];
			}
			return _Transitions[0];
		}
	
		private function createTransObject(n:String, xoffs:Number, yoffs:Number, alphastrt:Number, rotstrt:Number, xscalestrt:Number, yscalestrt:Number, xblurstrt:Number, yblurstrt:Number, britenessstrt:Number, dur:Number, twn:*, mb:Boolean = false):void {
			var o:Object = new Object();
			o.name = n;
			o.xoffset = xoffs;
			o.yoffset = yoffs;
			o.alphastart = alphastrt != -1 ? alphastrt : _DestinationProps.alpha;
			o.rotstart = rotstrt != -1 ? rotstrt : _DestinationProps.rotation;
			o.xscalestart = xscalestrt != -1 ? xscalestrt : _DestinationProps.scaleX;
			o.yscalestart = yscalestrt != -1 ? yscalestrt : _DestinationProps.scaleY;
			o.blurxstart = xblurstrt ? xblurstrt : 0;
			o.blurystart = yblurstrt ? yblurstrt : 0;
			o.brightstart = britenessstrt ? britenessstrt : 0;
			o.durration = dur ? dur : 1;
			o.tween = twn ? twn : Quad.easeOut;
			o.motionblur = mb;
			_Transitions.push(o);
		}

	}
	
}