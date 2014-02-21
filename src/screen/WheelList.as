package screen
{
	import assets.view.WheelList.WheelListItemSprite;

	import screen.controller.AbstractInteractiveScreen;
	import screen.model.ListItemModel;
	import screen.model.ListModel;

	import com.greensock.TweenMax;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quad;
	import com.greensock.plugins.MotionBlurPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.nudoru.constants.ObjectStatus;
	import com.nudoru.utilities.DisplayObjectUtilities;
	import com.nudoru.utilities.TimeKeeper;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;
	import flash.text.TextFieldAutoSize;

	/**
	 * Wheel click-list
	 * Basic carosel based on code from Lee Brimelow - http://www.gotoandlearn.com/play.php?id=32
	 * @author Matt Perkins
	 */
	public class WheelList extends AbstractInteractiveScreen
	{
		// ---------------------------------------------------------------------
		//
		// VARIABLES
		//
		// ---------------------------------------------------------------------
		protected var _Model:ListModel;
		protected var _CurrentCard:WheelListCard;
		protected var _QueuedCardIndex:int;
		/**
		 * Carosel props
		 */
		protected var _DiameterX:int = 175;
		protected var _DiameterY:int = 60;
		protected var _XCenter:int;
		protected var _YCenter:int;
		protected var _RotationSpeed:Number = .01;
		protected var _RotationSpeedFast:Number = .01;
		protected var _RotationSpeedSlow:Number = .005;
		protected var _RotationSpeedDimmed:Number = .001;
		protected var _ShowZ:Boolean = true;
		protected var _WheelDimmed:Boolean = false;
		protected var _PerspProj:PerspectiveProjection;
		protected var _ProtX:int = 0;
		protected var _ProtY:int = 0;
		protected var _ProtZ:int = 0;
		protected var _Ticker:TimeKeeper;

		// ---------------------------------------------------------------------
		//
		// CONSTRUCTION
		//
		// ---------------------------------------------------------------------
		/**
		 * Constructor
		 */
		public function WheelList()
		{
			super();
		}

		// ---------------------------------------------------------------------
		//
		// INITIALIZATION
		//
		// ---------------------------------------------------------------------
		/**
		 * Create model from loaded XML
		 * @param	data
		 */
		override protected function parseLoadedXML(data:XML):void
		{
			_Model = new ListModel(data);
		}

		// ---------------------------------------------------------------------
		//
		// RENDER
		//
		// ---------------------------------------------------------------------
		/**
		 * Draws the view
		 */
		override protected function renderScreen():void
		{
			TweenPlugin.activate([MotionBlurPlugin]);

			renderCommonScreenElements(_Model);

			// render the menu
			renderInteractiveObjects();
		}

		/**
		 * Draws the main menu items
		 */
		override protected function renderInteractiveObjects():void
		{
			_XCenter = screenWidth / 2;
			_YCenter = screenHeight / 2;

			if(_BodyTextTB) _YCenter += 50;

			_IObjects = [];

			var itemFloor:WheelListFloorSprite = new WheelListFloorSprite();
			itemFloor.name = "floor";
			itemFloor.scaleX = _DiameterX * .035;
			itemFloor.scaleY = _DiameterY * .035;
			itemFloor.x = _XCenter;
			itemFloor.y = _YCenter + 90;

			_IObjectHolder = new Sprite();

			_IObjectHolder.addChild(itemFloor);

			_InteractionLayer.addChild(_IObjectHolder);

			_PerspProj = new PerspectiveProjection();
			_PerspProj.fieldOfView = 100;
			_PerspProj.projectionCenter = new Point(_XCenter, _YCenter);

			_IObjectHolder.transform.perspectiveProjection = _PerspProj;

			// if 3 or fewer items, shrink the size of the circle
			if(_Model.numItems < 4)
			{
				_DiameterX /= 2;
				_DiameterY /= 2;
			}

			for(var i:int = 0, len:int = _Model.numItems; i < len; i++)
			{
				var cItem:ListItemModel = _Model.getItemByIdx(i);

				var item:WheelListItemSprite = new WheelListItemSprite();
				item.index = i;
				item.angle = i * ((Math.PI * 2) / len);

				item.text_txt.autoSize = TextFieldAutoSize.CENTER;
				item.text_txt.wordWrap = true;
				item.text_txt.multiline = true;
				item.text_txt.text = cItem.title;
				item.text_txt.y = int((item.text_txt.height / -2));

				item.hi_mc.alpha = 0;
				item.check_mc.alpha = 0;

				_IObjectHolder.addChild(item);
				_IObjects.push(item);

				// set up the "in" tween
				item.alpha = 0;
				TweenMax.to(item, 1, {alpha:1, ease:Quad.easeOut, delay:(i * .1) + 1});
			}

			// setup over, out, up and down mouse events
			enableAllInteractiveObjects();

			_IObjectHolder.z = 1000;
			_IObjectHolder.alpha = 0;
			TweenMax.to(_IObjectHolder, 3, {alpha:1, z:0, ease:Expo.easeOut, onComplete:onWheelNormalComplete});

			// controlls the animation on a timer
			_Ticker = new TimeKeeper("wheel_animater", 0, 33);
			_Ticker.addEventListener(TimeKeeper.TICK, onTick, false, 0, true);
			_Ticker.start();
		}

		// ---------------------------------------------------------------------
		//
		// WHEEL ANIMATION
		//
		// ---------------------------------------------------------------------
		/**
		 * Enable mouse interaction on the interactive object
		 */
		override protected function enableIObject(iobject:*):void
		{
			iobject.buttonMode = true;
			iobject.mouseChildren = false;
			iobject.addEventListener(MouseEvent.MOUSE_OVER, onIObjectOver, false, 0, true);
			iobject.addEventListener(MouseEvent.MOUSE_OUT, onIObjectOut, false, 0, true);
			iobject.addEventListener(MouseEvent.CLICK, onIObjectClick, false, 0, true);
		}

		/**
		 * Move the wheel to the side to show content 
		 */
		protected function wheelToSide():void
		{
			TweenMax.to(_IObjectHolder, 2, {x:screenWidth / -4, z:25, rotationX:0, rotationY:-15, rotationZ:0, ease:Quad.easeOut});
			_WheelDimmed = true;

			if(_BodyTextTB) TweenMax.to(_BodyTextTB, 1, {alpha:.3, ease:Quad.easeOut});
		}

		/**
		 * Move the wheel to the center
		 */
		protected function wheelToNormal():void
		{
			TweenMax.to(_IObjectHolder, 2, {x:0, y:0, z:0, rotationX:0, rotationY:0, rotationZ:0, ease:Quad.easeOut, onComplete:onWheelNormalComplete});
			_WheelDimmed = false;

			if(_BodyTextTB) TweenMax.to(_BodyTextTB, 1, {alpha:1, ease:Quad.easeOut});
		}

		/**
		 * Reset the matrix on the wheel
		 * @param	card
		 */
		protected function onWheelNormalComplete():void
		{
			DisplayObjectUtilities.resetMatrixTransformation(_IObjectHolder);
			// _IObjectHolder.transform.matrix = new Matrix(_IObjectHolder.scaleX, 0, 0, _IObjectHolder.scaleY, _IObjectHolder.x, _IObjectHolder.y);
		}

		protected function onTick(event:Event):void
		{
			for(var i:int = 0, len:int = _IObjects.length; i < len; i++)
			{
				var item:WheelListItemSprite = _IObjects[i];

				item.x = Math.cos(item.angle) * _DiameterX + _XCenter;
				item.y = Math.sin(item.angle) * _DiameterY + _YCenter;

				if(_ShowZ)
				{
					var scale:Number = item.y / (_YCenter + _DiameterY);
					item.scaleX = item.scaleY = scale;
				}

				item.angle += _WheelDimmed ? _RotationSpeedDimmed : _RotationSpeed;
			}

			arrange();
		}

		/**
		 * set the display list index (depth) of the Items according to their
		 * scaleX property so that the bigger the Item, the higher the index (depth)
		 * From: Matt Bury - http://matbury.com - http://www.actionscript.org/forums/showthread.php3?t=154403
		 */
		protected function arrange():void
		{
			// There isn't an Array.ASCENDING property so use DESCENDING and reverse()
			_IObjects.sortOn("scaleX", Array.DESCENDING | Array.NUMERIC);
			_IObjects.reverse();
			for(var i:int = 0, len:int = numIObjects; i < len; i++)
			{
				// +1 keeps the floor sprite on the bottom
				_IObjectHolder.setChildIndex(_IObjects[i] as WheelListItemSprite, i + 1);
			}
		}

		// ---------------------------------------------------------------------
		//
		// INTERACTION
		//
		// ---------------------------------------------------------------------
		/**
		 * Interactive object, mouse up event handler
		 * @param	e
		 */
		override protected function onIObjectOver(e:MouseEvent):void
		{
			// trace("InteractiveObject OVER " + e.target);
			TweenMax.to(e.target.hi_mc, .25, {alpha:1, ease:Quad.easeOut});
			_RotationSpeed = _RotationSpeedSlow;
		}

		/**
		 * Interactive object, mouse up event handler
		 * @param	e
		 */
		override protected function onIObjectOut(e:MouseEvent):void
		{
			// trace("InteractiveObject OUT " + e.target);
			TweenMax.to(e.target.hi_mc, 1, {alpha:0, ease:Quad.easeOut});
			_RotationSpeed = _RotationSpeedFast;
		}

		/**
		 * Interactive object, mouse up event handler
		 * @param	e
		 */
		override protected function onIObjectClick(e:MouseEvent):void
		{
			// trace("InteractiveObject CLICK " + e.target);
			wheelToSide();
			showItem(WheelListItemSprite(e.target).index);
		}

		/**
		 * Show the text for the selected item
		 * @param	item
		 */
		protected function showItem(item:int):void
		{
			if(_CurrentCard)
			{
				_QueuedCardIndex = item;
				removeCurrentCard();
				return;
			}

			// trace("show item " + item +" of " + _IObjects.length);
			var card:WheelListCard = createItemCard(_Model.getItemByIdx(item));
			card.x = 440;
			card.y = 120;

			_InteractionLayer.addChild(card);
			_CurrentCard = card;

			card.transform.perspectiveProjection = _PerspProj;
			card.alpha = 0;
			card.z = 300;
			card.rotationY = 45;

			TweenMax.to(card, 1, {z:0, alpha:1, rotationY:0, ease:Quad.easeOut, onComplete:cardInComplete, onCompleteParams:[card]});

			card.addEventListener(WheelListCard.EVENT_CLOSE, onCardCloseClick, false, 0, true);

			clearItemSelectView();

			TweenMax.to(getIObjectMCWithIndex(item).check_mc, .5, {alpha:1, ease:Expo.easeOut});
			TweenMax.to(getIObjectMCWithIndex(item), .5, {glowFilter:{color:0xe31932, blurX:10, blurY:10, strength:2, alpha:1}, ease:Quad.easeIn});
			TweenMax.to(getIObjectMCWithIndex(item), 1, {colorMatrixFilter:{brightness:1.3}, ease:Quad.easeIn});

			_Model.getItemByIdx(item).completed = true;

			if(_Model.allItemsCompleted())
			{
				setScreenStatusTo(ObjectStatus.COMPLETED);
			}
		}

		/**
		 * Reset matrix on the card
		 * @param	card
		 */
		protected function cardInComplete(card:WheelListCard):void
		{
			DisplayObjectUtilities.resetMatrixTransformation(card);
		}

		protected function onCardCloseClick(event:Event):void
		{
			_QueuedCardIndex = -1;
			removeCurrentCard();
			wheelToNormal();
		}

		protected function removeCurrentCard():void
		{
			clearItemSelectView();
			_CurrentCard.transform.perspectiveProjection = _PerspProj;
			TweenMax.to(_CurrentCard, .3, {z:100, alpha:0, rotationY:-45, ease:Quad.easeOut, onComplete:cardOutComplete, onCompleteParams:[_CurrentCard]});
		}

		protected function cardOutComplete(card:WheelListCard):void
		{
			card.destroy();
			_InteractionLayer.removeChild(card);
			_CurrentCard = undefined;
			if(_QueuedCardIndex >= 0) showItem(_QueuedCardIndex);
		}

		/**
		 * The objects in the array get shuffled around to do Z sorting
		 * @param	index
		 * @return
		 */
		protected function getIObjectMCWithIndex(index:int):WheelListItemSprite
		{
			for(var i:int = 0, len:int = _IObjects.length; i < len; i++)
			{
				if(_IObjects[i].index == index) return _IObjects[i];
			}
			return undefined;
		}

		/**
		 * Clear the selected view on each of the items
		 */
		protected function clearItemSelectView():void
		{
			for(var i:int = 0, len:int = _IObjects.length; i < len; i++)
			{
				TweenMax.to(_IObjects[i], 2, {glowFilter:{color:0xe31932, blurX:0, blurY:0, strength:0, alpha:0}, ease:Expo.easeOut});
				TweenMax.to(_IObjects[i], 1, {colorMatrixFilter:{brightness:1}, ease:Expo.easeOut});
			}
		}

		protected function createItemCard(item:ListItemModel):WheelListCard
		{
			var card:WheelListCard = new WheelListCard();
			card.render("<b>" + item.title + "</b><br><br>" + item.text);
			return card;
		}

		// ---------------------------------------------------------------------
		//
		// DESTROY
		//
		// ---------------------------------------------------------------------
		/**
		 * Remove listeners and display objects
		 */
		override public function destroy():void
		{
			_Ticker.stop();
			_Ticker.removeEventListener(TimeKeeper.TICK, onTick);
			_Ticker = undefined;

			super.destroy();
		}
	}
}