package scientia.model.structure
{
	import com.nudoru.constants.ObjectStatus;
	import com.nudoru.lms.scorm.InteractionObject;

	/**
	 * Scientia Node
	 * Used for all structure VOs
	 */
	public class NodeVO implements INodeVO
	{

		// ----------------------------------------------------------------------------------------------------------------------------------
		// VARS

		protected var _SourceData:XML;
		protected var _Status:int;
		protected var _InteractionObject:InteractionObject;

		protected var _Children:Array = [];
		protected var _CurrentChildIndex:int = 0;
		protected var _LastChildIndex:int = 0;

		// ----------------------------------------------------------------------------------------------------------------------------------
		// GETTER/SETTER

		public function get id():String
		{
			return _SourceData.@id;
		}

		public function get type():String
		{
			return _SourceData.@type;
		}

		public function get name():String
		{
			return _SourceData.@name;
		}

		public function get screenPath():String
		{
			return _SourceData.@path;
		}

		public function get dataURL():String
		{
			return _SourceData.@url;
		}

		public function get scored():Boolean
		{
			return _SourceData.@scored == "true";
		}

		public function get toc():Boolean
		{
			return _SourceData.@toc == "true";
		}

		public function get bg():String
		{
			return _SourceData.@bg;
		}

		public function get contentXML():XML
		{
			return _SourceData.content[0];
		}

		public function get status():int
		{
			return _Status;
		}

		public function set status(value:int):void
		{
			_Status = value;
		}

		public function get interactionObject():InteractionObject
		{
			return _InteractionObject;
		}

		public function set interactionObject(value:InteractionObject):void
		{
			_InteractionObject = value;
		}

		public function get numChildren():int
		{
			return _Children.length;
		}

		public function get currentChildIndex():int
		{
			return _CurrentChildIndex;
		}

		public function set currentChildIndex(value:int):void
		{
			_LastChildIndex = _CurrentChildIndex;
			_CurrentChildIndex = value;
		}

		public function get lastChildIndex():int
		{
			return _LastChildIndex;
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// INIT

		public function NodeVO(d:XML):void
		{
			_SourceData = d;
			status = ObjectStatus.INIT;
		}

		protected function parseXML():void
		{
			for(var i:int = 0, len:int = _SourceData.children().length(); i < len; i++)
			{
				_Children.push(new NodeVO(_SourceData.children()[i] as XML));
			}
		}
		
		// ----------------------------------------------------------------------------------------------------------------------------------
		// Get child data

		public function getChildID(index:int):String
		{
			return _Children[index].id;
		}

		public function getChildType(index:int):String
		{
			return  _Children[index].type;
		}

		public function getChildName(index:int):String
		{
			return  _Children[index].name;
		}

		public function getChildPath(index:int):String
		{
			return  _Children[index].screenPath;
		}

		public function getChildDataURL(index:int):String
		{
			return  _Children[index].dataURL;
		}

		public function getChildContentXML(index:int):XML
		{
			return  _Children[index].contentXML;
		}

		public function getChildStatus(index:int):int
		{
			return _Children[index].status;
		}

		public function setChildStatus(index:int, status:int):void
		{
			_Children[index].status = status;
		}

		// ----------------------------------------------------------------------------------------------------------------------------------
		// Navigation

		public function getCurrentChild():Object
		{
			return _Children[_CurrentChildIndex];
		}

		public function isNextChild():Boolean
		{
			return currentChildIndex < numChildren - 1;
		}

		public function isPreviousChild():Boolean
		{
			return currentChildIndex > 0;
		}

		public function firstChild():Object
		{
			currentChildIndex = 0;
			return getCurrentChild();
		}

		public function lastChild():Object
		{
			currentChildIndex = numChildren - 1;
			return getCurrentChild();
		}

		public function gotoPreviousChild():Object
		{
			if(isPreviousChild()) currentChildIndex--;
			return getCurrentChild();
		}

		public function gotoNextChild():Object
		{
			if(isNextChild()) currentChildIndex++;
			return getCurrentChild();
		}

		public function gotoChildByID(id:String):Object
		{
			var idx:int = getChildIndexByID(id);
			if(idx >= 0)
			{
				_CurrentChildIndex = idx;
				return _Children[idx];
			}
			return undefined;
		}

		public function getChildByIndex(index:int):Object
		{
			return _Children[index];
		}

		public function getChildIndexByID(id:String):int
		{
			for(var i:int = 0, len:int = _Children.length; i < len; i++)
			{
				if(_Children[i].id == id) return i;
			}
			return -1;
		}

		public function getChildByID(id:String):Object
		{
			var idx:int = getChildIndexByID(id);
			if(idx >= 0) return _Children[idx];
			return undefined;
		}
		
		// ----------------------------------------------------------------------------------------------------------------------------------
		// Status
		
		public function isComplete():Boolean
		{
			if(numChildren) return areAllChildrenCompleted();
			if(status >= ObjectStatus.COMPLETED) return true;
			return false;
		}
		
		/**
		 * Determins if all of the screens in the module are completed
		 */
		public function areAllChildrenCompleted():Boolean
		{
			for(var i:int = 0,len:int = numChildren;i < len;i++)
			{
				if(! _Children[i].isComplete()) return false;
			}
			return true;
		}

		/**
		 * Returns a string with the id and status for each screen in the course
		 */
		public function getAllChildrenStatusString():String
		{
			var statusString:String = "";
			for(var i:int = 0,len:int = numChildren;i < len;i++)
			{
				statusString += _Children[i].id + ":" + _Children[i].status + ",";
			}
			return statusString;
		}

		/**
		 * The number of scored screens in the module
		 */
		public function getNumberOfScoredChildren():int
		{
			var counter:int = 0;
			for(var i:int = 0, len:int = numChildren; i < len; i++)
			{
				if(_Children[i].scored) counter++;
			}
			return counter;
		}

		/**
		 * Returns the number of screens with a status matching status param
		 */
		public function getNumberOfChildrenWithStatus(status:int):int
		{
			var counter:int = 0;
			for(var i:int = 0, len:int = numChildren; i < len; i++)
			{
				if(_Children[i].status == status) counter++;
			}
			return counter;
		}
	}
}