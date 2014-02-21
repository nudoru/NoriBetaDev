  
/**
*
* DashDotLine.as  	May 2010
*
* @author Charles S.Davis
*
* Draws combination dashed-dotted lines
*
* Licensed under the MIT License
* 
* Copyright (c) 2009 Charles S.Davis
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
* 
* http://www.opensource.org/licenses/mit-license.php
*    
*/

package com.nudoru.visual.drawing
{
	import flash.display.Sprite;
	
	public class DashDotLine extends Sprite
	{
		public var lineLength:uint
		public var dashWidth:uint;
		public var dotWidth:uint;
		public var spacing:uint;
		public var lineWeight:uint;
		public var lineColor:uint;
		
		private var xPos:uint;
		
		/**
		 *	PARAMS:		@param  		lineLength			uint		total length of line to be drawn
		 *				@param			dashWidth			uint		width of each dash
		 * 	 			@param			dotWidth			uint    	width of each dot
		 *				@param			spacing				uint		spacing between each dash/dot
		 *				@param			lineWeight			uint		line weight/thickness
		 *				@param			lineColor			uint		color of dashes/dots 
		 *
		 *	USAGE:		import com.dtk.DashedLine;
		 *
		 *				var newLine:DashDotLine = new DashDotLine ( lineLength, dashWidth, dotWidth, spacing, lineWeight, lineColor );
		 *				newLine.rotation = angle; // (optional - in degrees)
		 *				newLine.x = x;
		 *				newLine.y = y;
		 *				addChild(newLine);
		 *                                                             
		 */
		public function DashDotLine( lineLength:uint, dashWidth:uint, dotWidth:uint, spacing:uint, lineWeight:uint, lineColor:uint ):void
		{
			this.lineLength  = lineLength;
			this.dashWidth   = dashWidth;
			this.dotWidth    = dotWidth;
			this.spacing     = spacing;
			this.lineWeight  = lineWeight;
			this.lineColor   = lineColor;
			
			drawDashedLine();
		}
		
		/**
		 *		Draw the line of dots & dashes
		 */
		private function drawDashedLine():void
		{
			// container to hold all dots & dashes
			var line:Sprite = new Sprite( );
			
			// initialize starting point of line
			xPos = 0;
			
			// loop through dashes, dots, spaces until line is
			// less than specified line length
			while ( xPos < lineLength )
			{
				// draw first dash
				var dash:Sprite = new Sprite( );
				dash.graphics.beginFill( lineColor );
				dash.graphics.drawRect( xPos, 0, dashWidth, lineWeight );
				dash.graphics.endFill( );
				line.addChild( dash );

				// add space
				xPos += ( dashWidth + spacing );
				
				// dot
				var dot:Sprite = new Sprite( );
				dot.graphics.beginFill( lineWeight );
				dot.graphics.drawRect( xPos, 0, dotWidth, lineWeight );
				dot.graphics.endFill( );
				line.addChild( dot );
				
				// space
				xPos += ( dotWidth + spacing );
			}
			addChild( line );
			
			// mask line to line length specified
			var masker:Sprite = new Sprite( );
			masker.graphics.beginFill( 0xff0000 );
			masker.graphics.drawRect( 0, 0, lineLength, lineWeight );
			masker.graphics.endFill( );
			addChild( masker );
				
			line.mask = masker;
		}
	}
}

