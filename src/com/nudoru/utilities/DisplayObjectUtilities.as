package com.nudoru.utilities
{
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Transform;
	
	
	/**
	 * Functions for working with DisplayObjects
	 * collected from: http://jacksondunstan.com/articles/519
	 * and other places
	 */
	public class DisplayObjectUtilities
	{

		/**
		 * This is a recursive function which takes a DisplayObjectContainer (such as a Sprite 
		 * or MovieClip) and rounds the x and y values of it and its children. It’s recursive 
		 * as the function calls itself when it encounters a child which is also a 
		 * DisplayObjectContainer so its children also get rounded. This recurses the entire
		 * display list beneath the passed DisplayObjectContainer, its children, its children’s 
		 * children etc.
		 * The point of this function is to make sure the passed DisplayObjectContainer and all 
		 * its children sit on whole pixels. This can be important when dealing with graphics which 
		 * aren’t sitting on whole pixels as it will cause them to appear blurry. This is probably
		 * most noticeable when dealing with pixel fonts.
		 * 
		 * From http://active.tutsplus.com/articles/roundups/15-useful-as3-snippets-on-snipplr-com/
		 */
		public static function roundPositions(displayObjectContainer:DisplayObjectContainer):void
		{
		    if (!(displayObjectContainer is Stage)) {
		        displayObjectContainer.x = Math.round(displayObjectContainer.x);
		        displayObjectContainer.y = Math.round(displayObjectContainer.y);
		    }
		    for (var i:uint = 0; i < displayObjectContainer.numChildren; i++) {
		        var child:DisplayObject = displayObjectContainer.getChildAt(i);
		        if (child is DisplayObjectContainer) {
		            roundPositions(child as DisplayObjectContainer);
		        } else {
		            child.x = Math.round(child.x);
		            child.y = Math.round(child.y);
		        }
		    }
		}

		/**
		 * Reset a display object's matrix transformation after a PerspectiveProjection transformation, essentially removing it
		 * Via - http://www.gotoandlearnforum.com/viewtopic.php?t=26426
		 * @param       sprite
		 */
		public static function resetMatrixTransformation(dobj:*):void
		{
			dobj.transform.matrix = new Matrix(dobj.scaleX, 0, 0, dobj.scaleY, dobj.x, dobj.y);
		}
		
		/**
		 * Via Nutrox at https://gist.github.com/778619
		 */
		public static function setToIsometricAngle(dobj:*):void
		{
			var iso:Matrix = new Matrix();
			iso.rotate( -45 * (Math.PI / 180)); // rotate anti-clockwise by 45 degrees
			iso.scale( 1.0, 0.5 );      // scale vertically by 50%
			iso.translate( 100, 100 );  // set position if needed
			dobj.transform.matrix = iso;
		}
		
		/**
		 * set the display list index (depth) of the Items according to their
		 * scaleX property so that the bigger the Item, the higher the index (depth)
		 * prop: "scaleX"
		 * From: Matt Bury - http://matbury.com - http://www.actionscript.org/forums/showthread.php3?t=154403
		 */
		public static function ZSortDOs(arry:Array, sortProperty:String, parentContainer:*):void {
			// There isn't an Array.ASCENDING property so use DESCENDING and reverse()
			arry.sortOn(sortProperty, Array.DESCENDING | Array.NUMERIC);
			arry.reverse();
			for(var i:int = 0, len:int = arry.length; i < len; i++) {
				parentContainer.setChildIndex(arry[i], i);
			}
		}
		
		/**
		*   Wait a given number of frames then call a callback
		*   @param numFrames Number of frames to wait before calling the callback
		*   @param callback Function to call once the given number of frames have passed
		*   @author Jackson Dunstan
		*/
		public static function wait(numFrames:uint, callback:Function): void
		{
			var obj:Shape = new Shape();
			obj.addEventListener(
				Event.ENTER_FRAME,
				function(ev:Event): void
				{
					numFrames--;
					if (numFrames == 0)
					{
						obj.removeEventListener(Event.ENTER_FRAME, arguments.callee);
						callback();
					}
				}
			);
		}

		/**
		*   Apply a scroll rect from (0,0) to (width,height)
		*   @param dispObj Display object to apply on
		*   @author Jackson Dunstan
		*/
		public static function applyNaturalScrollRect(dispObj:DisplayObject): void
		{
			dispObj.scrollRect = new Rectangle(0, 0, dispObj.width, dispObj.height);
		}
			
		/**
		*   Create a shape that is a simple solid color-filled rectangle
		*   @param width Width of the rectangle
		*   @param height Height of the rectangle
		*   @param color Color of the rectangle
		*   @param alpha Alpha of the rectangle
		*   @return The created shape
		*   @author Jackson Dunstan
		*/
		public static function createRectangleShape(width:uint, height:uint, color:uint, alpha:Number): Shape
		{
			var rect:Shape = new Shape();
		 
			var g:Graphics = rect.graphics;
			g.beginFill(color, alpha);
			g.drawRect(0, 0, width, height);
			g.endFill();
		 
			return rect;
		}

		/**
		*   Remove all children from a container and leave the bottom few
		*   @param container Container to remove from
		*   @param leave (optional) Number of bottom children to leave
		*   @author Jackson Dunstan
		*   
		*   TODO - optional function to call before it's removed
		*/
		public static function removeAllChildren(container:DisplayObjectContainer, leave:int = 0): void
		{
			while (container.numChildren > leave)
			{
				container.removeChildAt(leave);
			}
		}

		/**
		*   Check if a display object is visible. This checks all of its
		*   parents' visibilities.
		*   @param obj Display object to check
		*   @author Jackson Dunstan
		*/
		public static function isVisible(obj:DisplayObject): Boolean
		{
			for (var cur:DisplayObject = obj; cur != null; cur = cur.parent)
			{
				if (!cur.visible)
				{
					return false;
				}
			}
			return true;
		}

		/**
		*   Get the children of a container as an array
		*   @param container Container to get the children of
		*   @return The children of the given container as an array
		*   @author Jackson Dunstan
		*/
		public static function getChildren(container:DisplayObjectContainer): Array
		{
			var ret:Array = [];
		 
			var numChildren:int = container.numChildren;
			for (var i:int = 0; i < numChildren; ++i)
			{
				ret.push(container.getChildAt(i));
			}
		 
			return ret;
		}
		 
		/**
		*   Get the parents of a display object as an array
		*   @param obj Object whose parents should be retrieved
		*   @param includeSelf If obj should be included in the returned array
		*   @param stopAt Display object to stop getting parents at. Passing
		*                 null indicates that all parents should be included.
		*   @return An array of the parents of the given display object. This
		*           includes all parents unless stopAt is non-null. If stopAt is
		*           non-null, it and its parents will not be included in the
		*           returned array.
		*   @author Jackson Dunstan
		*/
		public static function getParents(obj:DisplayObject, includeSelf:Boolean=true, stopAt:DisplayObject=null): Array
		{
			var ret:Array = [];
		 
			for (var cur:DisplayObject = includeSelf ? obj : obj.parent;
				cur != stopAt && cur != null;
				cur = cur.parent
			)
			{
				ret.push(cur);
			}
		 
			return ret;
		}

		public static function relativePos(dO1:DisplayObject, dO2:DisplayObject):Point{
			var pos:Point = new Point(0,0);
			pos = dO1.localToGlobal(pos);
			pos = dO2.globalToLocal(pos);
			return pos;
		}

		/**
		 * Determines the full bounds of the display object regardless of masking elements.
		 * @param    displayObject    The display object to analyze.
		 * @return    the display object dimensions.
		 */
		public static function getFullBounds( displayObject:DisplayObject ):Rectangle
		{
			var bounds:Rectangle, transform:Transform, toGlobalMatrix:Matrix, currentMatrix:Matrix;
		 
			transform = displayObject.transform;
			currentMatrix = transform.matrix;
			toGlobalMatrix = transform.concatenatedMatrix;
			toGlobalMatrix.invert();
			transform.matrix = toGlobalMatrix;
		 
			bounds = transform.pixelBounds.clone();
		 
			transform.matrix = currentMatrix;
		 
			return bounds;
		}
		 
		/**
		 * Stops all timelines of the specified display object and its children.
		 * @param    displayObject    The display object to loop through.
		 */
		public static function stopAllTimelines( displayObject:DisplayObjectContainer ):void
		{
			var numChildren:int = displayObject.numChildren;
		 
			for (var i:int = 0; i < numChildren; i++ )
			{
				var child:DisplayObject = displayObject.getChildAt( i );
		 
				if ( child is DisplayObjectContainer ) 
				{
					if ( child is MovieClip ) 
					{
						MovieClip( child ).stop();
					}
		 
					stopAllTimelines( child as DisplayObjectContainer );
				}
			}
		}

		/**
		 * Returns a Bitmap instance of the supplied DisplayObject.
		 */
		public static function createBitmap(source : DisplayObject, useSmoothing : Boolean = true) : Bitmap
		{
			const bitmapData : BitmapData = new BitmapData(source.width, source.height, true, 0xffffff);
			bitmapData.draw(source);
		 
			const bitmap : Bitmap = new Bitmap(bitmapData);
			bitmap.smoothing = useSmoothing;
		 
			return bitmap;
		}

	}

}