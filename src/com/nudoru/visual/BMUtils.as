package com.nudoru.visual {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	
	public class BMUtils {
		
		public static const STDFILTERQUALITY	:int = BitmapFilterQuality.HIGH;
		
		public static function getBitmapCopy(s:*, x:int, y:int, w:int, h:int):Bitmap {
			if (!s || !s.width || !s.height) return undefined;
			/*var bm:BitmapData = new BitmapData(x + w, y + h, true, 0x00FFFFFF);
			bm.draw(s,null,null,null,new Rectangle(x,y,w,h));
			var b:Bitmap = new Bitmap(bm, "auto", true);
			return b;*/
			return new Bitmap(getBitmapdDataCopy(s, x, y, w, h), "auto", true);
		}
		
		public static function getBitmapdDataCopy(s:*, x:int, y:int, w:int, h:int):BitmapData {
			if (!s || !s.width || !s.height) return undefined;
			var bm:BitmapData = new BitmapData(x + w, y + h, true, 0x00FFFFFF);
			bm.draw(s, null, null, null, new Rectangle(x, y, w, h));
			return bm;
		}
		
		public static function clearAllFilters(s:*):void {
			s.filters = undefined;
		}
		
		public static function applyBlurFilter(s:*, blurx:Number, blury:Number):void {
            var quality:Number = STDFILTERQUALITY;
            var f:BlurFilter = new BlurFilter(blurx,blury,quality);
            var fArry:Array = s.filters;
            fArry.push(f);
            s.filters = fArry;
        }
		
		public static function applyGlowFilter(s:*, color:Number, alpha:Number, blur:Number, strength:Number, inner:Boolean=false):void {
            var knockout:Boolean = false;
            var quality:Number = STDFILTERQUALITY;
            var f:GlowFilter = new GlowFilter(color,alpha,blur,blur,strength,quality,inner,knockout);
            var fArry:Array = s.filters;
            fArry.push(f);
            s.filters = fArry;
        }
		
        public static function applyDropShadowFilter(s:*, distance:Number,  angle:Number, color:Number, alpha:Number, blur:Number, strength:Number):void {
            var inner:Boolean = false;
            var knockout:Boolean = false;
            var quality:Number = STDFILTERQUALITY;
			var f:DropShadowFilter = new DropShadowFilter(distance,angle,color,alpha,blur,blur,strength,quality,inner,knockout);
            var fArry:Array = s.filters;
            fArry.push(f);
            s.filters = fArry;
        }

		public static function saturate(s:*):void {
			var mySaturationData:SaturationData = new SaturationData();
			mySaturationData.saturate();
			var fArry:Array = s.filters;
            fArry.push(mySaturationData.getSaturation());
            s.filters = fArry;
		}
		
		public static function desaturate(s:*):void {
			var mySaturationData:SaturationData = new SaturationData();
			mySaturationData.desaturate();
			var fArry:Array = s.filters;
            fArry.push(mySaturationData.getSaturation());
            s.filters = fArry;
		}
		
		public static function normalcolor(s:*):void {
			var mySaturationData:SaturationData = new SaturationData();
			mySaturationData.reset();
			var fArry:Array = s.filters;
            fArry.push(mySaturationData.getSaturation());
            s.filters = fArry;
		}
		
		// Special presets
		
		public static function applyStdDarkGlow(t:Sprite):void {
			var glow:GlowFilter = new GlowFilter();
			glow.color = 0x000000;
			glow.alpha = .2;
			glow.blurX = 10;
			glow.blurY = 10;
			glow.quality = BitmapFilterQuality.MEDIUM;
			t.filters = [glow];
		}
		
		public static function applyStdDeepDarkGlow(t:Sprite):void {
			var glow:GlowFilter = new GlowFilter();
			glow.color = 0x000000;
			glow.alpha = .8;
			glow.blurX = 10;
			glow.blurY = 10;
			glow.quality = BitmapFilterQuality.MEDIUM;
			t.filters = [glow];
		}
		
		public static function applyStdLightGlow(t:Sprite):void {
			var glow:GlowFilter = new GlowFilter();
			glow.color = 0xffffff;
			glow.alpha = .5;
			glow.blurX = 10;
			glow.blurY = 10;
			glow.quality = BitmapFilterQuality.MEDIUM;
			t.filters = [glow];
		}
		
	}
	
}