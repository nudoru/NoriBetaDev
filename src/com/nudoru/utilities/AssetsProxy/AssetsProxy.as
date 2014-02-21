package com.nudoru.utilities.AssetsProxy
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import org.osflash.signals.Signal;


	/**
	 * Loads a SWF file and acts as a proxy for linked library items.
	 * @author Kevin Carmody - origional
	 * @author Matt Perkins - modifications - remove: Singleton, event dispatcher; add: Signals 
	 */
	dynamic public class AssetsProxy extends Proxy implements IAssetsProxy
	{
		protected var _assets				:ApplicationDomain;
		protected var _assetsLoader			:Loader = new Loader();
		
		protected var _onProgressSignal		:Signal = new Signal(Number);
		protected var _onAssetsLoadedSignal	:Signal = new Signal();
		protected var _onErrorSignal		:Signal = new Signal();

		/**
		 * Gets the loaded assets swf
		 */
		public function get assetsContent():DisplayObject
		{
			return _assetsLoader.content as DisplayObject;
		}

		/**
		 * To access classes in the loaded SWF
		 */
		public function get assetsAppDomain():ApplicationDomain
		{
			return _assetsLoader.contentLoaderInfo.applicationDomain;
		}

		public function get onProgressSignal():Signal
		{
			return _onProgressSignal;
		}

		public function get onAssetsLoadedSignal():Signal
		{
			return _onAssetsLoadedSignal;
		}

		public function get onErrorSignal():Signal
		{
			return _onErrorSignal;
		}

		/**
		 * Constructor
		 */
		public function AssetsProxy():void
		{
		}

		/**
		 * Proxy function that returns an item from the SWF's library
		 * 
		 * @param	name	Linkage ID of the object to return
		 * @return	requested library items
		 */
		flash_proxy override function getProperty(name:*):*
		{
			var _name:String = name.toString();
			var _ending:String = afterLast(_name, "_");
			var _loc1:Class = _assetsLoader.contentLoaderInfo.applicationDomain.getDefinition(name) as Class;

			var _loc2:*;

			switch(_ending)
			{
				case "btn":
					_loc2 = new _loc1() as SimpleButton;
					break;
				case "mc":
					_loc2 = new _loc1() as MovieClip;
					break;
				case "fnt":
					_loc2 = _loc1;
					break;
			}

			return _loc2;
		}

		/**
		 * @protected
		 */
		public function get assets():ApplicationDomain
		{
			return _assetsLoader.contentLoaderInfo.applicationDomain;
		}

		/**
		 * Loads a SWF file to get assets from.
		 * 
		 * @param	_url	SWF file to load
		 */
		public function load(_url:String):void
		{
			_assetsLoader.load(new URLRequest(_url));

			_assetsLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			_assetsLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
			_assetsLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
		}

		/**
		 * Error loading the file - file not found
		 */
		protected function onLoaderError(e:IOErrorEvent):void
		{
			onErrorSignal.dispatch();
		}

		/**
		 * Loading progress
		 */
		protected function onLoaderProgress(e:ProgressEvent):void
		{
			onProgressSignal.dispatch(Math.floor((e.bytesLoaded / e.bytesTotal) * 100));
		}

		/**
		 * Loading complete
		 */
		protected function onLoaderComplete(e:Event):void
		{
			_assetsLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoaderProgress);
			_assetsLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
			_assets = e.target.applicationDomain;

			onAssetsLoadedSignal.dispatch();
		}

		/**
		 *	Returns everything after the last occurence of the provided character in p_string.
		 *
		 *	@param p_string The string.
		 *
		 *	@param p_char The character or sub-string.
		 *
		 *	@returns String
		 *
		 * 	@langversion ActionScript 3.0
		 *	@playerversion Flash 9.0
		 *	@tiptext
		 */
		public function afterLast(p_string:String, p_char:String):String
		{
			if (p_string == null)
			{
				return '';
			}
			var idx:int = p_string.lastIndexOf(p_char);
			if (idx == -1)
			{
				return '';
			}
			idx += p_char.length;
			return p_string.substr(idx);
		}
	}
}