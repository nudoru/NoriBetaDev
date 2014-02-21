package com.nudoru.visual.drawing
{
	import flash.display.Graphics;
	
	/**
	 * http://www.pixelwit.com/blog/2007/07/draw-an-arc-with-actionscript/
	 *
	 * http://www.pixelwit.com/blog/2008/12/drawing-closed-arc-shape/
	 */
	public class SolidArc
	{
		
		/*
		 	lineStyle(0, 0xFF0000);
			drawArc(250, 250, 200, 45/360, -90/360, 20);
		*/
		/*public static function drawArc(centerX, centerY, radius, startAngle, arcAngle, steps){
			var twoPI = 2 * Math.PI;
			var angleStep = arcAngle/steps;
			var xx = centerX + Math.cos(startAngle * twoPI) * radius;
			var yy = centerY + Math.sin(startAngle * twoPI) * radius;
			moveTo(xx, yy);
			for(var i=1; i<=steps; i++){
				var angle = startAngle + i * angleStep;
				xx = centerX + Math.cos(angle * twoPI) * radius;
				yy = centerY + Math.sin(angle * twoPI) * radius;
				lineTo(xx, yy);
			}
		}*/
	
		/* 
		FROM PIXELWIT.COM (MODIFIED TO USE AS3 by Jeff T
		The DrawSolidArc function takes standard arc drawing
		arguments but the "radius" has been split into 2 different variables, "innerRadius" and "outerRadius".
		 
			var myArc:Shape = new Shape(); //or another DisplayObject
			myArc.graphics.lineStyle(3);
			myArc.graphics.beginFill(0x000000, 0.50);
			drawSolidArc (myArc,250, 250, 80, 200, 45/360, -90/360, 20);
			myArc.graphics.endFill();
			this.addChild(myArc);
		
			Draw 4 colored arcs around a circle without any overlap.
			
			beginFill(0xFF0000, 50);
			DrawSolidArc (250, 250, 80, 200, 45/360, -90/360, 20);
			beginFill(0x00FF00, 50);
			DrawSolidArc (250, 250, 80, 200, 135/360, -90/360, 20);
			beginFill(0x0000FF, 50);
			DrawSolidArc (250, 250, 80, 200, 225/360, -90/360, 20);
			beginFill(0xFFFF00, 50);
			DrawSolidArc (250, 250, 80, 200, 315/360, -90/360, 20);
		*/
		public static function draw(drawObj:Object, centerX:Number,centerY:Number,innerRadius:Number,outerRadius:Number,startAngle:Number,arcAngle:Number,steps:int=20):void {
			//
			// Used to convert angles [ratio] to radians.
			var twoPI:Number = 2 * Math.PI;
			//
			// How much to rotate for each point along the arc.
			var angleStep:Number = arcAngle/steps;
			//
			// Variables set later.
			var angle:Number, i:int, endAngle:Number;
			//
			// Find the coordinates of the first point on the inner arc.
			var xx:Number = centerX + Math.cos(startAngle * twoPI) * innerRadius;
			var yy:Number = centerY + Math.sin(startAngle * twoPI) * innerRadius;
			//
			//Store the coordinates.
			var xxInit:Number=xx;
			var yyInit:Number=yy;
			//
			// Move to the first point on the inner arc.
			drawObj.graphics.moveTo(xx,yy);
			//
			// Draw all of the other points along the inner arc.
			for(i=1; i<=steps; i++) {
				angle = (startAngle + i * angleStep) * twoPI;
				xx = centerX + Math.cos(angle) * innerRadius;
				yy = centerY + Math.sin(angle) * innerRadius;
				drawObj.graphics.lineTo(xx,yy);
			}
			//
			// Determine the ending angle of the arc so you can
			// rotate around the outer arc in the opposite direction.
			endAngle = startAngle + arcAngle;
			//
			// Start drawing all points on the outer arc.
			for(i=0;i<=steps;i++) {
				//
				// To go the opposite direction, we subtract rather than add.
				angle = (endAngle - i * angleStep) * twoPI;
				xx = centerX + Math.cos(angle) * outerRadius;
				yy = centerY + Math.sin(angle) * outerRadius;
				drawObj.graphics.lineTo(xx, yy);
			}
			//
			// Close the shape by drawing a straight
			// line back to the inner arc.
			drawObj.graphics.lineTo(xxInit,yyInit);
		}
		
	}
	
}