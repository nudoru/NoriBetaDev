﻿package com.nudoru.sheet {

	import flash.display.Sprite;
	import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
	import flash.text.AntiAliasType;
	
	import com.nudoru.visual.drawing.GradBox;
	import com.nudoru.visual.drawing.RoundGradBox;
	import com.nudoru.utilities.AutoContent;
	
	public class POTextBox extends PageObject implements IPageObject  {
		
		private var _POObject					:Sprite;
		
		private var _Content					:String;
		private var _FontName					:String;
		private var _FontAlign					:String;
		private var _FontSize					:int;
		private var _FontColor					:int;
		private var _FontLeading				:int;
		private var _IsBold						:Boolean;
		private var _IsItalic					:Boolean;
		private var _Selectable					:Boolean = false;
		private var _Radius						:int = 0;
		private var _BaseColor					:int;
		private var _LineColor					:int;
		private var _LightColor					:int;
		private var _DarkColor					:int;
		private var _Shadow						:Boolean = true;
		private var _BorderWidth				:int = 10;
		
		private var _AutoContent				:AutoContent = new AutoContent();
		
		public override function getObject():* { return _POObject; }
		
		public function POTextBox(p:Sheet, t:Sprite, x:XMLList):void {
			super(p, t, x);
			parseTextData();
			render();
		}
		
		public override function render():void {
			_Status = STATUS_INIT;
			createContainers(_TargetSprite);
			createText();
			drawBoxes();
			applyDisplayProperties();
			loaded = true;
		}
		
		private function createText():void {
			var holder:Sprite = new Sprite();
			var box:Sprite = new Sprite();
			var field:TextField = new TextField();
			
			field.name = "text_txt";
			field.width = _Width;
			field.x = _BorderWidth;
			field.y = _BorderWidth;

			field.height = 1;				// this will adjust with autosize, just setting since the default is 100
			if (_FontAlign) field.autoSize = _FontAlign;	// should probably use constants here, but that would require an if block, TextFieldAutoSize.LEFT;
				else field.autoSize = TextFieldAutoSize.LEFT;

			field.wordWrap = true;
			field.multiline = true;
            field.selectable = _Selectable;
			field.embedFonts = true;
			field.antiAliasType = AntiAliasType.ADVANCED;
			
            var format:TextFormat = new TextFormat();
            if(_FontName) format.font = _FontName;
			if(_FontAlign) format.align = _FontAlign;
            if(_FontColor) format.color = _FontColor;
            if(_FontSize) format.size = _FontSize;
			if(_FontLeading) format.leading = _FontLeading;
			if(_IsBold) format.bold = _IsBold;
			if(_IsItalic) format.italic = _IsItalic;

            field.defaultTextFormat = format;
			field.htmlText = _Content;
			field.mouseWheelEnabled = false;
			//field.width = field.textWidth + 5;
			//field.cacheAsBitmap = true;
			
			var bxy:int = 0;
			var bw:int = field.width+(_BorderWidth*2);
			var bh:int = field.height+(_BorderWidth*2);

			if(_Radius > 0) {
				var rbx:RoundGradBox = new RoundGradBox(box, bxy, bxy, bw, bh, _Shadow, _Radius, {bc:_BaseColor, oc:_LineColor, lc:_LightColor, dc:_DarkColor});
			} else {
				var gbx:GradBox = new GradBox(box, bxy, bxy, bw, bh, _Shadow, {bc:_BaseColor, oc:_LineColor, lc:_LightColor, dc:_DarkColor});
			}
			
			holder.addChild(box);
			holder.addChild(field);
			
			_POObject = holder;
			_ObjContainer.addChild(_POObject);
			
		}

		private function parseTextData():void {
			_Content = _AutoContent.applyContentFunction(_XMLData.content);
			_FontName = _XMLData.fontstyle;
			_FontAlign = _XMLData.fontstyle.@align;
			_FontSize = int(_XMLData.fontstyle.@size);
			_FontColor = int(_XMLData.fontstyle.@color);
			_FontLeading = int(_XMLData.fontstyle.@leading);
			_IsBold = isBool(_XMLData.fontstyle.@bold);
			_IsItalic = isBool(_XMLData.fontstyle.@italic);
			_Selectable = isBool(_XMLData.selectable);
			_BorderWidth = int(_XMLData.borderwidth);
			_Radius = int(_XMLData.radius);
			_BaseColor = int(_XMLData.basecolor);
			_LineColor = int(_XMLData.linecolor);
			_LightColor = int(_XMLData.lightcolor);
			_DarkColor = int(_XMLData.darkcolor);
			_Shadow = isBool(_XMLData.shadow);
		}
		
		public override function destroy():void {
			removeListeners();
			_ObjContainer.removeChild(_POObject);
			_POObject = null;
		}
		
	}
}