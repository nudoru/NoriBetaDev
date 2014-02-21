package scientia.model.structure
{
	import scientia.view.ScreenTransitionType;

	/**
	 * Value object of a structure
	 */
	public class StructureVO extends NodeVO implements IStructureVO
	{

		/**
		 * Is progress in the module forward or backwards
		 */
		public function get currentNavigationDirection():int
		{
			if(_CurrentChildIndex > _LastChildIndex) return ScreenTransitionType.DIR_NEXT;
			if(_CurrentChildIndex < _LastChildIndex) return ScreenTransitionType.DIR_BACK;
			if(_Children[currentChildIndex].currentChildIndex > _Children[currentChildIndex].lastChildIndex) return ScreenTransitionType.DIR_NEXT;
			if(_Children[currentChildIndex].currentChildIndex < _Children[currentChildIndex].lastChildIndex) return ScreenTransitionType.DIR_BACK;
			return ScreenTransitionType.DIR_NONE;
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// Constructor and init

		public function StructureVO(d:XML):void
		{
			super(d);
			parseXML();
		}

		override protected function parseXML():void
		{
			for(var i:int = 0, len:int = _SourceData.children().length(); i < len; i++)
			{
				_Children.push(new ModuleVO(_SourceData.children()[i] as XML));
			}
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// Typical navigation
		/**
		 * Go to the first screen in the structure
		 * @return
		 */
		public function firstScreen():IScreenVO
		{
			_CurrentChildIndex = 0;
			return _Children[_CurrentChildIndex].firstChild();
		}

		/**
		 * Returns the current screen
		 * @return
		 */
		public function getCurrentScreen():IScreenVO
		{
			return _Children[_CurrentChildIndex].getCurrentChild() as IScreenVO;
		}

		/**
		 * Goes to the screen id
		 * @param	id
		 * @return
		 */
		public function gotoScreenByID(id:String):IScreenVO
		{
			for(var m:int = 0, mlen:int = _Children.length; m < mlen; m++)
			{
				if(_Children[m].gotoChildByID(id))
				{
					_CurrentChildIndex = m;
					return getCurrentScreen() as IScreenVO;
				}
			}
			return undefined;
		}

		/**
		 * Test for a previous linear screen
		 * TODO add support for wrapping
		 * @return
		 */
		public function isLinearPreviousScreen():Boolean
		{
			return _Children[_CurrentChildIndex].isPreviousChild();
		}

		/**
		 * Test for a next linear screen
		 * TODO add support for wrapping
		 * @return
		 */
		public function isLinearNextScreen():Boolean
		{
			return _Children[_CurrentChildIndex].isNextChild();
		}

		/**
		 * Go to the next screen in the current module
		 * TODO add support for wrapping
		 * @return
		 */
		public function gotoPreviousScreen():IScreenVO
		{
			return _Children[_CurrentChildIndex].gotoPreviousChild() as IScreenVO;
		}

		/**
		 * Go to the next screen in the current module
		 * TODO add support for wrapping
		 * @return
		 */
		public function gotoNextScreen():IScreenVO
		{
			return _Children[_CurrentChildIndex].gotoNextChild() as IScreenVO;
		}

		/**
		 * Goes to the screen id
		 * @param	id
		 * @return
		 */
		public function getScreenByID(id:String):IScreenVO
		{
			for(var m:int = 0, mlen:int = _Children.length; m < mlen; m++)
			{
				var screen:IScreenVO = _Children[m].getChildByID(id);
				if(screen) return screen;
			}
			return undefined;
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// GET DATA ABOUT SCREENS IN MODULES (grandchildren)
		
		public function getCurrentModuleScreenIndex():int
		{
			return _Children[_CurrentChildIndex].currentChildIndex;
		}

		public function getCurrentModuleNumScreens():int
		{
			return _Children[_CurrentChildIndex].numChildren;
		}

		public function getModuleScreenID(mindex:int, sindex:int):String
		{
			return _Children[mindex].getChildByIndex(sindex).id;
		}

		public function getModuleScreenType(mindex:int, sindex:int):String
		{
			return  _Children[mindex].getChildByIndex(sindex).type;
		}

		public function getModuleScreenName(mindex:int, sindex:int):String
		{
			return  _Children[mindex].getChildByIndex(sindex).name;
		}

		public function getModuleScreenStatus(mindex:int, sindex:int):int
		{
			return _Children[mindex].getChildByIndex(sindex).status;
		}

		public function setModuleScreenStatus(mindex:int, sindex:int, status:int):void
		{
			_Children[mindex].getChildByIndex(sindex).status = status;
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// Status

		public function areAllModulesCompleted():Boolean
		{
			for(var i:int = 0,len:int = numChildren;i < len;i++)
			{
				if(! _Children[i].areAllChildrenCompleted()) return false;
			}
			return true;
		}

		public function getAllScreenStatusString():String
		{
			var statusString:String = "";
			for(var i:int = 0,len:int = numChildren;i < len;i++)
			{
				statusString += _Children[i].getAllChildrenStatusString() + ",";
			}
			return statusString;
		}

		public function getNumberOfScoredScreens():int
		{
			var counter:int = 0;
			for(var i:int = 0, len:int = numChildren; i < len; i++)
			{
				counter += _Children[i].getNumberOfScoredChildren();
			}
			return counter;
		}

		public function getNumberOfScreensWithStatus(status:int):int
		{
			var counter:int = 0;
			for(var i:int = 0, len:int = numChildren; i < len; i++)
			{
				counter += _Children[i].getNumberOfChildrenWithStatus(status);
			}
			return counter;
		}
	}
}