package com.nudoru.components {
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	/**
	 * Loads a graphic or SWF file
	 * 
	 * Sample:
	 * 
		import com.nudoru.components.ImageLoader;
		import com.nudoru.components.NudoruComponentEvent;

		var il:ImageLoader = new ImageLoader();
		il.initialize({url:"assets/testimage.jpg"});
		il.addEventListener(NudoruComponentEvent.EVENT_PROGRESS, onImageProgress);
		il.addEventListener(NudoruComponentEvent.EVENT_LOADED, onImageLoaded);
		il.addEventListener(NudoruComponentEvent.EVENT_IOERROR, onImageError);
		il.load();

		function onImageProgress(event:NudoruComponentEvent):void
		{
			trace(event.data)
		}

		function onImageLoaded(event:Event):void
		{
			var image:Sprite = new Sprite();
			image.addChild(il.content);
			this.addChild(image);
		}

		function onImageError(event:Event):void
		{
			trace("ERROR: "+event.type);
		}
	 */
	public class ImageLoader extends AbstractDataComponent implements IAbstractDataComponent {
		
		private var _url			:String;
		private var _loader			:Loader;

		/**
		 * The data loaded from the XML file
		 */
		override public function get content():*
		{
			// will be a DisplayObject
			return _loader.content;
		}

		/**
		 * Returns true if the file is a graphic file, false if it is a SWF
		 */
		public function get isBitmapImage():Boolean {
			var fn:String = _url.toLowerCase();
			if(fn.indexOf(".jpg") > 1 || fn.indexOf(".png") > 1 ||fn.indexOf(".gif") > 1) return true;
			return false;
		}
		
		/**
		 * Constructor
		 */
		public function ImageLoader():void 
		{
			super();
		}
		
		/**
		 * Initialize
		 */
		override public function initialize(data:*=null):void 
		{			
			_url = data.url;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_INITIALIZED));
		}
		
		/**
		 * Load the file
		 * 
		 * @param	url	The file to load
		 */
		override public function load():void 
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress, false, 0, true);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadError, false, 0, true);
			
			var context:LoaderContext = new LoaderContext();
			// Set this flag to true when you are loading an image (JPEG, GIF, or PNG) from outside the calling SWF file's own domain, 
			// and you expect to need access to the content of that image from ActionScript. 
			context.checkPolicyFile = true;
			
			dispatchProgressEvent(0);
			
			_loader.load(new URLRequest(_url), context);
		}
		
		/**
		 * File not found
		 * @param	event
		 */
		private function onLoadError(event:Event):void 
		{
			removeListeners();
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_IOERROR));
		}
		
		private function onLoadProgress(event:ProgressEvent):void 
		{
			dispatchProgressEvent(calculatePercentage(event.bytesLoaded, event.bytesTotal));
		}
		
		private function onLoadComplete(event:Event):void 
		{
			if (isBitmapImage) {
				// smooth the loaded image for better appearance
				event.target.content.smoothing = true;
			}
			removeListeners();
			
			dispatchProgressEvent(100);
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_LOADED));
		}
		
		private function removeListeners():void {
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
		}
		
		/**
		 * Close the loader and remove events
		 */
		override public function destroy():void 
		{
			removeListeners();
			
			try 
			{
				_loader.close();
			} 
			catch (e:*) 
			{ 
				// error here if the stream had finished already
			}
			
			_loader.unloadAndStop(true);
			_loader = null;
			
			dispatchEvent(new ComponentEvent(ComponentEvent.EVENT_DESTROYED));
		}
	}
	
}