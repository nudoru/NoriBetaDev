package com.nudoru.noriplugins.appview.context
{
	import com.nudoru.components.ComponentEvent;
	import com.nudoru.components.XMLLoader;
	import com.nudoru.debug.Debugger;
	import com.nudoru.nori.context.AbstractContext;
	import com.nudoru.nori.events.InitProgressEvent;
	import com.nudoru.utilities.AssetsProxy.AssetsProxy;
	import com.nudoru.utilities.AssetsProxy.IAssetsProxy;
	import flash.display.DisplayObjectContainer;


	/**
	 * Encapsulates functionality for sub context to load the context XML and assets SWF file prior
	 * to building a more robust context
	 */
	public class AppContext extends AbstractContext implements IAppContext
	{
		
		protected var _contentXMLLoader:XMLLoader;
		protected var _assetsProxy:IAssetsProxy;

		protected var _contentXMLFileURL:String = "";
		protected var _assetsSWFFileURL:String = "";

		// ---------------------------------------------------------------------
		//
		// INITIALIZE
		//
		// ---------------------------------------------------------------------
		/**
		 * Constructor
		 */
		public function AppContext():void
		{
			super();
		}

		/**
		 * Starting
		 * 
		 * Steps:
		 *	 1. load the content XML file
		 *	 2. load the assets SWF file
		 * 	 In a sub class - 3. assemble
		 * 	 In a sub class - 4. dispatch complete signal
		 * 	 In a sub class - 5. run called from the outside
		 */
		override protected function onStartUp():void
		{
			Debugger.instance.initializeMDebugger(this);

			loadContent();
		}

		// ---------------------------------------------------------------------
		//
		// 1 LOAD REQUIRED EXTERNAL FILES
		//
		// ---------------------------------------------------------------------
		/**
		 * Load the content.xml file which contains settings neccessary for the app to build
		 */
		private function loadContent():void
		{
			Debugger.instance.add("LOADING CONTENT: "+_contentXMLFileURL, this);
			
			_contentXMLLoader = new XMLLoader();
			_contentXMLLoader.addEventListener(ComponentEvent.EVENT_LOADED, onXMLLoaded, false, 0, true);
			_contentXMLLoader.addEventListener(ComponentEvent.EVENT_IOERROR, onXMLError, false, 0, true);
			_contentXMLLoader.addEventListener(ComponentEvent.EVENT_PARSE_ERROR, onXMLError, false, 0, true);
			_contentXMLLoader.initialize({url:_contentXMLFileURL});
			_contentXMLLoader.load();
		}

		/**
		 * The XML file as successfully loaded.
		 */
		private function onXMLLoaded(event:ComponentEvent):void {
			_contentXMLLoader.removeEventListener(ComponentEvent.EVENT_LOADED, onXMLLoaded);
			_contentXMLLoader.removeEventListener(ComponentEvent.EVENT_IOERROR, onXMLError);
			_contentXMLLoader.removeEventListener(ComponentEvent.EVENT_PARSE_ERROR, onXMLError);
			
			loadAssets();
		}
		
		/**
		 * There was either an IO (file not found) or parsing (malformed XML) error event
		 * 
		 * @param	event	X
		 */
		private function onXMLError(event:ComponentEvent):void {
			_contentXMLLoader.removeEventListener(ComponentEvent.EVENT_LOADED, onXMLLoaded);
			_contentXMLLoader.removeEventListener(ComponentEvent.EVENT_IOERROR, onXMLError);
			_contentXMLLoader.removeEventListener(ComponentEvent.EVENT_PARSE_ERROR, onXMLError);
			
			Debugger.instance.add("ERROR LOADING MODEL CONTENT", this);
		}

		/**
		 * Loas the assets swf file
		 */
		protected function loadAssets():void
		{
			Debugger.instance.add("LOADING ASSETS: "+_assetsSWFFileURL, this);
			
			_assetsProxy = new AssetsProxy();
			_assetsProxy.onErrorSignal.addOnce(onAssetsError);
			_assetsProxy.onProgressSignal.add(onAssetsProgress);

			// Build it when the assets are loaded
			_assetsProxy.onAssetsLoadedSignal.addOnce(assemble);
			_assetsProxy.load(_assetsSWFFileURL);
		}

		/**
		 * Problem loading the assets
		 */
		protected function onAssetsError():void
		{
			Debugger.instance.add("ERROR LOADING ASSEST CONTENT", this);
		}

		/**
		 * Rebroadcasts the assets loading progress as a progress event that will be picked up by the loader
		 * and used to indicate loading progress
		 */
		protected function onAssetsProgress(progress:Number):void
		{
			eventDispatcher.dispatchEvent(new InitProgressEvent(InitProgressEvent.EVENT_PROGRESS, progress));
		}

		// ---------------------------------------------------------------------
		//
		// 2 CONSTRUCTION
		//
		// ---------------------------------------------------------------------
		/**
		 * Builds the app
		 */
		protected function assemble():void
		{
			//
		}

		// ---------------------------------------------------------------------
		//
		// 3 RUN
		//
		// ---------------------------------------------------------------------
		/**
		 * Startup
		 */
		override public function run():void
		{
			//
		}
	}
}