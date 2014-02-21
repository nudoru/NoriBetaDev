package com.nudoru.noriplugins.appview
{
	import com.nudoru.nori.events.InitProgressEvent;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.Font;

	/**
	 * Provides base functionality for a preloader to load a context main file
	 * 
	 * @author Matt Perkins
	 */
	public class AbstractContextLoader extends Sprite
	{
		protected var _noriMainSWF:String;
		protected var _noriLoader:Loader;
		protected var _noriContextSprite:Sprite;

		public function AbstractContextLoader()
		{
		}

		protected function load(url:String):void
		{
			_noriMainSWF = url;
			createLoadingView();
			beginLoading();
		}

		protected function createLoadingView():void
		{
			_noriContextSprite = new Sprite();
			this.addChild(_noriContextSprite);
		}

		/**
		 * Begin loading the framework
		 */
		protected function beginLoading():void
		{
			_noriLoader = new Loader();
			_noriLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
			_noriLoader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
			_noriLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false, 0, true);

			var context:LoaderContext = new LoaderContext();
			// Set this flag to true when you are loading an image (JPEG, GIF, or PNG) from outside the calling SWF file's own domain,
			// and you expect to need access to the content of that image from ActionScript.
			context.checkPolicyFile = true;

			// after the file is loaded, listen for events from it
			this.addEventListener(InitProgressEvent.EVENT_PROGRESS, onContentProgress, false, 0, true);

			_noriLoader.load(new URLRequest(_noriMainSWF), context);
		}

		// -------------------------------------------------------------------------------------------------------------
		// LOADING
		/**
		 * File not found
		 * @param	event
		 */
		protected function onLoadError(event:Event):void
		{
			removeListeners();
		}

		protected function onLoadProgress(event:ProgressEvent):void
		{
			//
		}

		protected function onLoadComplete(event:Event):void
		{
			removeListeners();
			_noriContextSprite.addChild(_noriLoader.content);
		}

		protected function removeListeners():void
		{
			_noriLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_noriLoader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_noriLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
		}

		protected function onContentProgress(e:InitProgressEvent):void
		{
			//
		}

		protected function removeContentListeners():void
		{
			this.removeEventListener(InitProgressEvent.EVENT_PROGRESS, onContentProgress);
		}

		// --------------------------------------------------------------------
		// UTILITY
		/**
		 * Called from a app view to determine if the app was loaded by the view or not
		 * The view needs to register fonts loaded from the assets swf file to either this level or the
		 * load the level to ensure that they're available to all swfs/views
		 */
		public function getName():String
		{
			return "NoriLoader";
		}

		/**
		 * Called from a view in the framework, this registers fonts on this level to make the available to everythin
		 */
		public function registerFont(font:Class):void
		{
			try
			{
				Font.registerFont(font);
			}
			catch (e:*)
			{
				trace("loader FAILED to add font");
			}
		}
	}
}
